import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';
import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../socket/socket_service.dart';
import '../wallet/wallet_screen.dart';
import '../pk/pk_media.dart';
import '../services/gift_intent_store.dart';
import 'live_preview.dart';

class LiveListScreen extends StatefulWidget {
  const LiveListScreen({super.key});
  @override
  State<LiveListScreen> createState() => _LiveListScreenState();
}

class _LiveListScreenState extends State<LiveListScreen> {
  final _api = ApiClient.instance.dio;
  List<dynamic> _lives = [];
  String? _error;
  bool _busy = false, _roomOpen = false;
  final _title = TextEditingController();
  Timer? _refresh;
  @override
  void initState() {
    super.initState();
    _load();
    _refresh = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_roomOpen) _load();
    });
  }

  Future<void> _load() async {
    try {
      final response = await _api.get('/live/list');
      if (mounted) {
        setState(() {
          _lives = response.data as List;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    }
  }

  Future<void> _open(int id) async {
    setState(() => _roomOpen = true);
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => LiveRoomScreen(liveId: id)));
    if (!mounted) return;
    setState(() => _roomOpen = false);
    await _load();
  }

  Future<void> _start() async {
    if (_busy) return;
    final value = _title.text.trim();
    setState(() => _busy = true);
    try {
      final result = await _api.post('/live/start', data: {'title': value});
      if (mounted) await _open(int.parse('${result.data['liveId']}'));
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _refresh?.cancel();
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: const Column(
        children: [
          Text(
            'Go Live',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            'Start or discover a live stream',
            style: TextStyle(fontSize: 11, color: Color(0xff8c8c98)),
          ),
        ],
      ),
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _lives.length + 1,
        itemBuilder: (context, index) {
          if (index == 0)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff181818),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xff242424)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.fiber_manual_record,
                        color: Color(0xfffe2c55),
                        size: 25,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Start broadcasting',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Add a title so viewers know what your live is about.',
                          style: TextStyle(color: Color(0xffa7a7b2)),
                        ),
                      ),
                      TextField(
                        controller: _title,
                        maxLength: 120,
                        decoration: const InputDecoration(
                          labelText: 'Live title',
                          hintText: 'What are you streaming?',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _busy ? null : _start,
                        child: Text(_busy ? 'Starting…' : 'Start Live'),
                      ),
                    ],
                  ),
                ),
                if (_error != null)
                  ListTile(title: Text(_error!), onTap: _load),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Currently Live · ${_lives.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_lives.isEmpty)
                  const ListTile(title: Text('No one is live right now.')),
              ],
            );
          final live = _lives[index - 1];
          final id = int.parse('${live['id']}');
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: () => _open(id),
                child: AspectRatio(
                  aspectRatio: 9 / 12,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (!_roomOpen)
                        LivePreview(key: ValueKey(id), liveId: id),
                      const Positioned(
                        top: 12,
                        left: 12,
                        child: Chip(
                          label: Text('LIVE'),
                          backgroundColor: Color(0xfffe2c55),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.black54,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${live['title'] ?? 'Live Stream'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '@${live['username'] ?? 'user'} · ${live['viewers'] ?? 0} viewers',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class LiveRoomScreen extends StatefulWidget {
  const LiveRoomScreen({super.key, required this.liveId});
  final int liveId;
  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  final _api = ApiClient.instance.dio;
  final _socket = SocketService();
  final _room = Room();
  final _comment = TextEditingController();
  Map<String, dynamic>? _live, _battle, _invite;
  List<dynamic> _comments = [];
  String? _error;
  int _viewers = 0, _likes = 0;
  bool _creator = false, _broadcasting = false, _busy = false, _ended = false;
  bool _connecting = false;
  Map<String, dynamic>? _pendingGift;
  final _giftStore = const GiftIntentStore();
  int? _giftUserId;
  @override
  void initState() {
    super.initState();
    _room.addListener(_changed);
    _socket.onConnect = () {
      _socket.emit('join_live', {'liveId': widget.liveId});
      _loadComments();
      _changed();
    };
    _socket.on('viewer_count', (data) {
      _viewers = int.tryParse('${data['viewerCount']}') ?? 0;
      _changed();
    });
    _socket.on('receive_live_like', (data) {
      _likes = int.tryParse('${data['totalLikes']}') ?? 0;
      _changed();
    });
    _socket.on('receive_live_comment', (_) => _loadComments());
    _socket.on('live_ended', (_) {
      _ended = true;
      _room.disconnect();
      _changed();
    });
    for (final event in ['pk_started', 'pk_battle_state']) {
      _socket.on(event, (data) async {
        if (_broadcasting) await _camera();
        _battle = Map<String, dynamic>.from(data);
        _changed();
      });
    }
    _socket.on('pk_score_updated', (data) {
      if (_battle != null) {
        _battle = {
          ..._battle!,
          'score_a': data['scoreA'],
          'score_b': data['scoreB'],
        };
      }
      _changed();
    });
    for (final event in ['pk_ended', 'pk_finished']) {
      _socket.on(event, (_) {
        _battle = null;
        _changed();
      });
    }
    _socket.on('pk_request_received', (data) {
      _invite = Map<String, dynamic>.from(data);
      _changed();
    });
    _socket.on('pk_request_ended', (_) {
      _invite = null;
      _changed();
    });
    for (final event in ['pk_error', 'gift_error', 'comment_error']) {
      _socket.on(event, (data) {
        _error = '${data['message']}';
        _changed();
      });
    }
    _socket.on('connect_error', (_) {
      _error = 'Live connection failed. Check your connection.';
      _changed();
    });
    _socket.on('disconnect', (_) => _changed());
    _connect();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _connect() async {
    if (_connecting) return;
    _connecting = true;
    try {
      final live = await _api.get('/live/${widget.liveId}');
      if (!mounted) return;
      _live = Map<String, dynamic>.from(live.data);
      _likes = int.tryParse('${_live!['total_likes']}') ?? 0;
      _viewers = int.tryParse('${_live!['viewers']}') ?? 0;
      _giftUserId = context.read<AuthController>().user!.id;
      _pendingGift = await _giftStore.load(_giftUserId!, widget.liveId);
      if (!mounted) return;
      _creator =
          '${_live!['user_id']}' ==
          '${context.read<AuthController>().user!.id}';
      if (!_socket.connected) await _socket.connect();
      final media = await _api.post('/live/${widget.liveId}/media-token');
      if (!mounted) return;
      if ((media.data['role'] == 'creator') != _creator) {
        throw StateError('Media role mismatch');
      }
      if (_room.connectionState != ConnectionState.connected) {
        await _room.connect('${media.data['url']}', '${media.data['token']}');
      }
      if (!mounted) {
        await _room.disconnect();
        return;
      }
      _error = null;
    } catch (error) {
      _error =
          'Could not connect to live: ${error is StateError ? error.message : error.toString()}';
    } finally {
      _connecting = false;
      _changed();
    }
  }

  Future<void> _loadComments() async {
    try {
      final response = await _api.get('/live-comment/${widget.liveId}');
      if (mounted) setState(() => _comments = response.data['data'] as List);
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    }
  }

  Future<void> _action(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      _error = error is StateError ? error.message : apiErrorMessage(error);
    } finally {
      _busy = false;
      _changed();
    }
  }

  Future<void> _camera() => _action(() async {
    if (_room.connectionState != ConnectionState.connected ||
        _room.localParticipant == null) {
      throw StateError(
        'Wait for the media connection before enabling the camera.',
      );
    }
    final enable = !_broadcasting;
    await _room.localParticipant?.setCameraEnabled(enable);
    try {
      await _room.localParticipant?.setMicrophoneEnabled(enable);
    } catch (error) {
      // Keep the working camera, as the web broadcaster does when audio fails.
      _error =
          'Video is live, but microphone could not start. Check microphone permission. $error';
    }
    _broadcasting = enable;
  });
  bool _emitLive(String event, Map<String, dynamic> data) {
    if (!_socket.connected) {
      setState(
        () =>
            _error = 'Live connection is reconnecting. Try again in a moment.',
      );
      _socket.connect();
      return false;
    }
    _socket.emit(event, data);
    return true;
  }

  Future<void> _gift() async {
    if (_busy || _live == null || _giftUserId == null) return;
    await _action(() async {
      if (_pendingGift == null) {
        final gifts = (await _api.get('/gifts')).data as List;
        if (!mounted) return;
        final gift = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          builder: (context) => SafeArea(
            child: ListView(
              children: [
                for (final item in gifts)
                  ListTile(
                    title: Text('${item['name']}'),
                    subtitle: Text('${item['coin_cost']} coins'),
                    onTap: () =>
                        Navigator.pop(context, Map<String, dynamic>.from(item)),
                  ),
              ],
            ),
          ),
        );
        if (gift == null) return;
        if (!mounted) return;
        final me = context.read<AuthController>().user!.id.toString();
        final recipients = <String>{
          '${_live!['user_id']}',
          if (_battle?['creator_a_id'] != null) '${_battle!['creator_a_id']}',
          if (_battle?['creator_b_id'] != null) '${_battle!['creator_b_id']}',
          for (final participant in _battle?['participants'] as List? ?? [])
            '${participant['user_id']}',
        }..remove(me);
        if (recipients.isEmpty) throw StateError('No eligible gift recipient');
        String? receiver = recipients.first;
        if (recipients.length > 1) {
          receiver = await showModalBottomSheet<String>(
            context: context,
            builder: (context) => SafeArea(
              child: ListView(
                children: [
                  const ListTile(title: Text('Choose gift recipient')),
                  for (final id in recipients)
                    ListTile(
                      title: Text('Participant #$id'),
                      onTap: () => Navigator.pop(context, id),
                    ),
                ],
              ),
            ),
          );
        }
        if (receiver == null) return;
        final random = Random.secure();
        final key = List.generate(
          24,
          (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
        ).join();
        _pendingGift = {
          'liveId': widget.liveId,
          'receiverId': receiver,
          'giftId': gift['id'],
          'operationKey': key,
          'idempotencyKey': key,
        };
      }
      // Keep the same intent/key on an acknowledgement timeout. A retry must
      // never debit again. Only the server confirms completion and scores.
      await _giftStore.save(_giftUserId!, widget.liveId, _pendingGift!);
      final result = await _socket.request('send_live_gift', _pendingGift);
      if (result['success'] != true) {
        throw StateError('${result['message'] ?? 'Gift failed'}');
      }
      await _giftStore.clear(_giftUserId!, widget.liveId);
      _pendingGift = null;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gift sent')));
      }
    });
  }

  @override
  void dispose() {
    _socket.emit('leave_live', {'liveId': widget.liveId});
    _socket.dispose();
    _room.removeListener(_changed);
    _room.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = context.read<AuthController>().user?.id.toString();
    final canLeavePK =
        _battle != null &&
        ('${_battle!['creator_a_id']}' == me ||
            '${_battle!['creator_b_id']}' == me ||
            (_battle!['participants'] as List? ?? []).any(
              (p) => '${p['user_id']}' == me,
            ));
    final tracks = <VideoTrack>[
      if (_creator)
        ...?_room.localParticipant?.videoTrackPublications
            .map((p) => p.track)
            .whereType<VideoTrack>(),
      for (final participant in _room.remoteParticipants.values)
        ...participant.videoTrackPublications
            .map((p) => p.track)
            .whereType<VideoTrack>(),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        title: Text(
          _ended ? 'Live ended' : '${_live?['title'] ?? 'Connecting…'}',
        ),
        actions: [
          if (!_creator)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Leave Live'),
            ),
          if (_creator)
            IconButton(
              tooltip: 'Earnings',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => WalletScreen(liveId: widget.liveId),
                ),
              ),
              icon: const Icon(Icons.account_balance_wallet),
            ),
          if (canLeavePK)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _action(() async {
                      final result = await _socket.request(
                        'leave_pk',
                        _battle!['id'],
                      );
                      if (result['success'] != true) {
                        throw StateError('${result['message']}');
                      }
                      _battle = null;
                    }),
              child: const Text('Leave PK'),
            ),
          if (_creator && !_ended)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _action(() async {
                      await _api.post('/live/end/${widget.liveId}');
                      _ended = true;
                      await _room.disconnect();
                    }),
              child: const Text('End live'),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _ended
                ? const Center(child: Text('This live has ended'))
                : _battle != null
                ? PKMedia(
                    key: ValueKey(_battle!['id']),
                    battleId: _battle!['id'].toString(),
                  )
                : tracks.isEmpty
                ? const Center(child: Text('Waiting for camera'))
                : Row(
                    children: [
                      for (final track in tracks)
                        Expanded(
                          child: VideoTrackRenderer(
                            track,
                            fit: VideoViewFit.cover,
                          ),
                        ),
                    ],
                  ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black45,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0, .45, 1],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight + 8),
                if (_error != null)
                  ListTile(
                    title: Text(_error!),
                    trailing: IconButton(
                      onPressed: _connect,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                if (_busy) const LinearProgressIndicator(),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '$_viewers viewers · $_likes likes${_socket.connected ? '' : ' · Reconnecting…'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_battle != null)
                  Text(
                    'PK: ${_battle!['score_a'] ?? 0} : ${_battle!['score_b'] ?? 0}',
                  ),
                if (_invite != null)
                  Row(
                    children: [
                      const Expanded(child: Text('PK invitation')),
                      TextButton(
                        onPressed: () {
                          _socket.emit('pk_accept_request', _invite!['id']);
                          setState(() => _invite = null);
                        },
                        child: const Text('Accept'),
                      ),
                      TextButton(
                        onPressed: () {
                          _socket.emit('pk_reject_request', _invite!['id']);
                          setState(() => _invite = null);
                        },
                        child: const Text('Decline'),
                      ),
                    ],
                  ),
                const Spacer(),
                SizedBox(
                  height: 130,
                  child: ListView(
                    children: [
                      for (final item in _comments)
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          title: Text(
                            '${item['username'] ?? ''}: ${item['message']}',
                          ),
                        ),
                    ],
                  ),
                ),
                if (!_ended)
                  SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (_creator && _battle == null)
                              TextButton.icon(
                                onPressed: _busy ? null : _camera,
                                label: Text(
                                  _broadcasting
                                      ? 'Stop camera'
                                      : 'Enable camera',
                                ),
                                icon: Icon(
                                  _broadcasting
                                      ? Icons.videocam_off
                                      : Icons.videocam,
                                ),
                              ),
                            IconButton(
                              tooltip: 'Like live',
                              onPressed: () => _emitLive('send_live_like', {
                                'liveId': widget.liveId,
                              }),
                              icon: const Icon(Icons.favorite),
                            ),
                            if (!_creator || _battle != null)
                              TextButton(
                                onPressed: _busy ? null : _gift,
                                child: Text(
                                  _pendingGift == null ? 'Gift' : 'Retry gift',
                                ),
                              ),
                            if (!_creator && _live != null)
                              TextButton(
                                onPressed: () => _socket.emit('pk_request', {
                                  'receiverId': _live!['user_id'],
                                }),
                                child: const Text('Request PK'),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _comment,
                                decoration: const InputDecoration(
                                  hintText: 'Say something…',
                                  fillColor: Colors.black45,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(24),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_comment.text.trim().isEmpty) {
                                  return;
                                }
                                final sent = _emitLive('send_live_comment', {
                                  'liveId': widget.liveId,
                                  'message': _comment.text.trim(),
                                });
                                if (sent) _comment.clear();
                              },
                              icon: const Icon(Icons.send),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
