import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../socket/socket_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiClient.instance.dio;
  final _socket = SocketService();
  List<dynamic> _rows = [];
  String? _error;
  bool _busy = false, _more = true;
  @override
  void initState() {
    super.initState();
    _socket.on('notification', (_) => _load());
    _socket.onConnect = _load;
    _socket.connect();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final response = await _api.get(
        '/notifications',
        queryParameters: {'limit': 20, 'offset': more ? _rows.length : 0},
      );
      final rows = response.data['notifications'] as List;
      if (mounted) {
        setState(() {
          _rows = more ? [..._rows, ...rows] : rows;
          _more = rows.length == 20;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _read(String path) async {
    try {
      await _api.post(path);
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notifications'),
      actions: [
        TextButton(
          onPressed: () => _read('/notifications/read-all'),
          child: const Text('Read all'),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) ListTile(title: Text(_error!), onTap: _load),
          if (!_busy && _rows.isEmpty)
            const ListTile(title: Text('No notifications yet')),
          for (final row in _rows)
            ListTile(
              leading: Icon(
                '${row['is_read']}' == '1'
                    ? Icons.notifications_none
                    : Icons.notifications_active,
              ),
              title: Text('${row['message']}'),
              subtitle: Text('${row['created_at']}'),
              onTap: () => _read('/notifications/${row['id']}/read'),
            ),
          if (_more)
            TextButton(
              onPressed: _busy ? null : () => _load(more: true),
              child: const Text('Load more'),
            ),
        ],
      ),
    ),
  );
}
