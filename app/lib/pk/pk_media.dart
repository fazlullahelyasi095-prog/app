import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../socket/socket_service.dart';

/// Mirrors the web client's pk-webrtc signaling protocol. Permission to
/// publish comes exclusively from pk-webrtc:join, never from a client role.
class PKMedia extends StatefulWidget {
  const PKMedia({super.key, required this.battleId});
  final String battleId;
  @override
  State<PKMedia> createState() => _PKMediaState();
}

class _PKMediaState extends State<PKMedia> {
  final _socket = SocketService(joinPersonalRoom: false);
  final _peers = <String, RTCPeerConnection>{};
  final _renderers = <String, RTCVideoRenderer>{};
  final _connectionIds = <String, String>{};
  Future<void> _signaling = Future.value();
  int _connectionSequence = 0;
  final _pending = <String, List<RTCIceCandidate>>{};
  MediaStream? _local;
  String _status = 'Connecting to PK';
  bool _canPublish = false, _busy = false;
  Map<String, dynamic> _configuration = {};
  Map<String, dynamic> get _scope => {'battleId': widget.battleId};
  @override
  void initState() {
    super.initState();
    _socket.onConnect = () => _signal(_join);
    _socket.on('pk-webrtc:publisher-ready', (data) {
      _socket.emit('pk-webrtc:subscriber-ready', {
        ..._scope,
        'publisherSocketId': data['publisherSocketId'],
      });
    });
    _socket.on(
      'pk-webrtc:subscriber-ready',
      (data) => _signal(() async {
        if (!_canPublish || _local == null) return;
        final remoteId = '${data['subscriberSocketId']}';
        final id = 'send:$remoteId';
        if (_peers.containsKey(id)) return;
        _connectionIds[id] =
            '${DateTime.now().microsecondsSinceEpoch}-${_connectionSequence++}';
        final peer = await _peer(id, publish: true);
        final offer = await peer.createOffer();
        await peer.setLocalDescription(offer);
        _socket.emit('pk-webrtc:offer', {
          ..._scope,
          'targetSocketId': remoteId,
          'connectionId': _connectionIds[id],
          'description': offer.toMap(),
        });
      }),
    );
    _socket.on(
      'pk-webrtc:offer',
      (data) => _signal(() async {
        final remoteId = '${data['sourceSocketId']}';
        final id = 'receive:$remoteId';
        final connectionId = '${data['connectionId'] ?? ''}';
        if (_peers.containsKey(id) && _connectionIds[id] == connectionId) {
          return;
        }
        _connectionIds[id] = connectionId;
        final peer = await _peer(id);
        final description = data['description'];
        await peer.setRemoteDescription(
          RTCSessionDescription(description['sdp'], description['type']),
        );
        await _flush(id, peer);
        final answer = await peer.createAnswer();
        await peer.setLocalDescription(answer);
        _socket.emit('pk-webrtc:answer', {
          ..._scope,
          'targetSocketId': remoteId,
          'connectionId': _connectionIds[id],
          'description': answer.toMap(),
        });
      }),
    );
    _socket.on(
      'pk-webrtc:answer',
      (data) => _signal(() async {
        final id = 'send:${data['sourceSocketId']}';
        final peer = _peers[id];
        if (peer == null ||
            peer.signalingState !=
                RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
          return;
        }
        if (data['connectionId'] != null &&
            data['connectionId'] != _connectionIds[id]) {
          return;
        }
        final description = data['description'];
        await peer.setRemoteDescription(
          RTCSessionDescription(description['sdp'], description['type']),
        );
        await _flush(id, peer);
      }),
    );
    _socket.on(
      'pk-webrtc:ice-candidate',
      (data) => _signal(() async {
        final remoteId = '${data['sourceSocketId']}';
        final connectionId = '${data['connectionId'] ?? ''}';
        final matching = _connectionIds.keys
            .where(
              (key) =>
                  key.substring(key.indexOf(':') + 1) == remoteId &&
                  (connectionId.isEmpty || _connectionIds[key] == connectionId),
            )
            .toList();
        final id = matching.length == 1 ? matching.first : 'receive:$remoteId';
        final pendingKey = '$remoteId|$connectionId';
        final value = data['candidate'];
        final candidate = RTCIceCandidate(
          value['candidate'],
          value['sdpMid'],
          value['sdpMLineIndex'],
        );
        final peer = _peers[id];
        if (matching.length == 1 &&
            peer != null &&
            await peer.getRemoteDescription() != null) {
          await peer.addCandidate(candidate);
        } else {
          (_pending[pendingKey] ??= []).add(candidate);
        }
      }),
    );
    _socket.on(
      'pk-webrtc:peer-left',
      (data) => _signal(() async {
        await _close('send:${data['socketId']}');
        await _close('receive:${data['socketId']}');
      }),
    );
    _socket.on('connect_error', (_) {
      if (mounted) setState(() => _status = 'PK connection failed');
    });
    _socket.connect();
  }

  Future<void> _signal(Future<void> Function() action) {
    _signaling = _signaling.then((_) async {
      if (mounted) await _guard(action);
    });
    return _signaling;
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _status = 'PK media: $error');
    }
  }

  Future<void> _join() async {
    for (final id in _peers.keys.toList()) {
      await _close(id);
    }
    _configuration = await _socket.request('webrtc:get-config', null);
    final result = await _socket.request('pk-webrtc:join', _scope);
    if (!mounted) return;
    if (result['success'] != true) throw StateError('${result['message']}');
    setState(() {
      _canPublish = result['canPublish'] == true;
      _status = 'PK connected';
    });
    if (_local != null && _canPublish) {
      _socket.emit('pk-webrtc:publisher-ready', _scope);
    }
    _socket.emit('pk-webrtc:find-publishers', _scope);
  }

  Future<void> _publish() async {
    if (!_canPublish || _busy || _local != null) return;
    setState(() => _busy = true);
    await _guard(() async {
      final stream = await navigator.mediaDevices.getUserMedia({
        'video': {'facingMode': 'user'},
        'audio': true,
      });
      if (!mounted) {
        for (final track in stream.getTracks()) {
          await track.stop();
        }
        await stream.dispose();
        return;
      }
      _local = stream;
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      if (!mounted) {
        await renderer.dispose();
        return;
      }
      renderer.srcObject = stream;
      setState(() {
        _renderers['local'] = renderer;
      });
      _socket.emit('pk-webrtc:publisher-ready', _scope);
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<RTCPeerConnection> _peer(String id, {bool publish = false}) async {
    await _peers.remove(id)?.close();
    await _renderers.remove(id)?.dispose();
    final peer = await createPeerConnection(_configuration);
    if (!mounted) {
      await peer.close();
      throw StateError('PK room closed');
    }
    _peers[id] = peer;
    if (publish && _local != null) {
      for (final track in _local!.getTracks()) {
        await peer.addTrack(track, _local!);
      }
    }
    peer.onIceCandidate = (candidate) {
      if (mounted && _peers[id] == peer && candidate.candidate?.isNotEmpty == true) {
        _socket.emit('pk-webrtc:ice-candidate', {
          ..._scope,
          'targetSocketId': id.substring(id.indexOf(':') + 1),
          'connectionId': _connectionIds[id],
          'candidate': candidate.toMap(),
        });
      }
    };
    peer.onTrack = (event) => _guard(() async {
      if (event.streams.isEmpty || !mounted || _peers[id] != peer) return;
      // Audio and video can arrive together. Reserve the renderer before await.
      if (_renderers.containsKey(id)) return;
      final renderer = RTCVideoRenderer();
      _renderers[id] = renderer;
      await renderer.initialize();
      if (!mounted || _renderers[id] != renderer) {
        await renderer.dispose();
        return;
      }
      renderer.srcObject = event.streams.first;
      setState(() {});
    });
    return peer;
  }

  Future<void> _flush(String id, RTCPeerConnection peer) async {
    final remoteId = id.substring(id.indexOf(':') + 1);
    final key = '$remoteId|${_connectionIds[id] ?? ''}';
    for (final candidate in _pending.remove(key) ?? <RTCIceCandidate>[]) {
      await peer.addCandidate(candidate);
    }
  }

  Future<void> _close(String id) async {
    await _peers.remove(id)?.close();
    await _renderers.remove(id)?.dispose();
    final remoteId = id.substring(id.indexOf(':') + 1);
    _pending.remove('$remoteId|${_connectionIds.remove(id) ?? ''}');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _socket.emit('pk-webrtc:leave', _scope);
    _socket.dispose();
    for (final peer in _peers.values) {
      unawaited(peer.close());
    }
    for (final renderer in _renderers.values) {
      unawaited(renderer.dispose());
    }
    for (final track in _local?.getTracks() ?? <MediaStreamTrack>[]) {
      unawaited(track.stop());
    }
    _local?.dispose();
    _peers.clear();
    _renderers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(_status),
      if (_canPublish && _local == null)
        TextButton(
          onPressed: _busy ? null : _publish,
          child: const Text('Enable PK camera & microphone'),
        ),
      Expanded(
        child: Row(
          children: [
            for (final entry in _renderers.entries)
              Expanded(
                child: RTCVideoView(entry.value, mirror: entry.key == 'local'),
              ),
          ],
        ),
      ),
    ],
  );
}
