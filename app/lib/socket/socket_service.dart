import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/app_config.dart';
import '../core/storage.dart';
import '../api/api_client.dart';

/// One authenticated connection per screen session. Listeners are installed
/// before connect; reconnect callbacks restore server room membership.
class SocketService {
  SocketService({this.joinPersonalRoom = true});
  final bool joinPersonalRoom;
  io.Socket? _socket;
  bool _disposed = false;
  final Map<String, void Function(dynamic)> _listeners = {};
  void Function()? onConnect;

  void on(String event, void Function(dynamic) listener) {
    _listeners[event] = listener;
    _socket?.on(event, listener);
  }

  Future<void> connect() async {
    if (_disposed) return;
    if (_socket != null) {
      if (!_socket!.connected) _socket!.connect();
      return;
    }
    final token = await SecureStore.token();
    if (_disposed || token == null) return;
    final socket = io.io(
      AppConfig.socketBase,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );
    _socket = socket;
    for (final entry in _listeners.entries) {
      socket.on(entry.key, entry.value);
    }
    socket.onConnect((_) {
      if (joinPersonalRoom) socket.emit('join');
      onConnect?.call();
    });
    socket.onConnectError((error) {
      final message = error is Map ? '${error['message']}' : '$error';
      if ([
        'Authentication required',
        'Invalid token',
        'Invalid authentication token',
      ].contains(message)) {
        ApiClient.instance.onUnauthorized?.call();
      }
    });
    socket.connect();
  }

  bool get connected => _socket?.connected == true;
  void emit(String event, [dynamic data]) {
    if (connected) _socket!.emit(event, data);
  }

  Future<Map<String, dynamic>> request(String event, dynamic data) async {
    if (!connected) throw StateError('Connection unavailable. Try again.');
    final result = Completer<Map<String, dynamic>>();
    void acknowledge(dynamic value) {
      if (!result.isCompleted) {
        if (value is Map) {
          result.complete(Map<String, dynamic>.from(value));
        } else {
          result.completeError(StateError('Invalid server acknowledgement'));
        }
      }
    }

    if (data == null) {
      _socket!.emitWithAck(event, null, ack: acknowledge);
    } else {
      _socket!.emitWithAck(event, data, ack: acknowledge);
    }
    return result.future.timeout(const Duration(seconds: 15));
  }

  void dispose() {
    _disposed = true;
    _socket?.dispose();
    _socket = null;
  }
}
