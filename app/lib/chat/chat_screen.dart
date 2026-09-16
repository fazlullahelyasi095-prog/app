import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../services/chat_service.dart';
import '../socket/socket_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.conversationId, this.title = 'Messages'});
  final int? conversationId;
  final String title;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _service = ChatService();
  final _socket = SocketService();
  final _text = TextEditingController();
  XFile? _attachment;
  List<Map<String, dynamic>> _rows = [];
  String? _error;
  bool _loading = true, _sending = false;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _socket.onConnect = () {
      if (widget.conversationId != null) {
        _socket.emit('join_chat', widget.conversationId);
      }
      _load();
    };
    for (final event in ['receive_message', 'conversation_updated']) {
      _socket.on(event, (_) => _load());
    }
    _socket.connect();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final id = widget.conversationId;
      final rows = id == null
          ? await _service.conversations()
          : await _service.messages(id);
      if (!mounted || generation != _generation) return;
      setState(() {
        _rows = rows;
        _error = null;
        _loading = false;
      });
      if (id != null) {
        await _service.readIncoming(
          id,
          rows,
          context.read<AuthController>().user?.id,
        );
      }
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = apiErrorMessage(error);
          _loading = false;
        });
      }
    }
  }

  Future<void> _send() async {
    if (_sending || (_text.text.trim().isEmpty && _attachment == null)) return;
    setState(() => _sending = true);
    try {
      final attachment = _attachment;
      MultipartFile? media;
      if (attachment != null) {
        final extension = attachment.name.split('.').last.toLowerCase();
        final mime =
            attachment.mimeType ??
            switch (extension) {
              'jpg' || 'jpeg' => 'image/jpeg',
              'png' => 'image/png',
              'gif' => 'image/gif',
              'webp' => 'image/webp',
              'heic' => 'image/heic',
              'heif' => 'image/heif',
              'mp4' || 'm4v' => 'video/mp4',
              'mov' => 'video/quicktime',
              'webm' => 'video/webm',
              '3gp' => 'video/3gpp',
              _ => 'application/octet-stream',
            };
        media = await MultipartFile.fromFile(
          attachment.path,
          filename: attachment.name,
          contentType: DioMediaType.parse(mime),
        );
      }
      await _service.send(widget.conversationId!, _text.text, media: media);
      if (!mounted) return;
      _text.clear();
      setState(() => _attachment = null);
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final media = await ImagePicker().pickMedia();
      if (mounted && media != null) setState(() => _attachment = media);
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    }
  }

  @override
  void dispose() {
    if (widget.conversationId != null) {
      _socket.emit('leave_chat', widget.conversationId);
    }
    _socket.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.light,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.conversationId == null ? 'Inbox' : widget.title),
        actions: [
          IconButton(
            tooltip: 'Refresh messages',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null) Text(_error!),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (!_loading && _rows.isEmpty)
                    const ListTile(title: Text('No messages yet')),
                  for (final row in _rows)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: widget.conversationId == null
                          ? CircleAvatar(
                              radius: 27,
                              backgroundColor: const Color(0xfff1f1f2),
                              child: Text(
                                '${row['username'] ?? '?'}'.isEmpty
                                    ? '?'
                                    : '${row['username'] ?? '?'}'
                                          .substring(0, 1)
                                          .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      title: Text(
                        '${row['username'] ?? 'Message'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${widget.conversationId == null ? row['last_message'] ?? 'Start chatting' : row['message']}',
                        maxLines: widget.conversationId == null ? 2 : null,
                        overflow: widget.conversationId == null
                            ? TextOverflow.ellipsis
                            : null,
                      ),
                      trailing: widget.conversationId == null
                          ? Badge(
                              isLabelVisible:
                                  (int.tryParse('${row['unread_count']}') ??
                                      0) >
                                  0,
                              label: Text('${row['unread_count'] ?? 0}'),
                              backgroundColor: AppTheme.accent,
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            )
                          : row['mediaUrl'] != null
                          ? const Icon(Icons.attachment)
                          : null,
                      onTap: () async {
                        if (widget.conversationId == null) {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ChatScreen(
                                conversationId: int.parse(
                                  '${row['conversation_id']}',
                                ),
                                title: '${row['username']}',
                              ),
                            ),
                          );
                          _load();
                        } else if (row['mediaUrl'] != null) {
                          await launchUrl(
                            Uri.parse(AppConfig.mediaUrl('${row['mediaUrl']}')),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
          if (_attachment != null)
            ListTile(
              leading: const Icon(Icons.attachment),
              title: Text(
                _attachment!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: 'Remove attachment',
                onPressed: _sending
                    ? null
                    : () => setState(() => _attachment = null),
                icon: const Icon(Icons.close),
              ),
            ),
          if (widget.conversationId != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Attach photo or video',
                      onPressed: _sending ? null : _pickAttachment,
                      icon: const Icon(Icons.attach_file),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _text,
                        enabled: !_sending,
                        decoration: const InputDecoration(hintText: 'Message'),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    IconButton(
                      onPressed: _sending ? null : _send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
