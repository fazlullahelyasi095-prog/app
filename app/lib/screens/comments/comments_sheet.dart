import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../core/app_config.dart';
import '../../models/comment.dart';
import '../../services/social_service.dart';
import '../../widgets/app_states.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.videoId,
    this.onAdded,
    this.service,
  });
  final int videoId;
  final VoidCallback? onAdded;
  final SocialService? service;
  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _text = TextEditingController();
  late Future<List<VideoComment>> _comments;
  bool _sending = false;
  int _added = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      _comments = (widget.service ?? SocialService()).comments(widget.videoId);
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || _text.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await (widget.service ?? SocialService()).addComment(
        widget.videoId,
        _text.text,
      );
      widget.onAdded?.call();
      if (!mounted) return;
      _text.clear();
      _added++;
      setState(_load);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      child: SizedBox(
        height:
            (MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom) *
            .72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, _added),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<VideoComment>>(
                future: _comments,
                builder: (_, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const AppLoadingState();
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: apiErrorMessage(snapshot.error!),
                      onRetry: () => setState(_load),
                    );
                  }
                  final comments = snapshot.data ?? const [];
                  if (comments.isEmpty) {
                    return const AppEmptyState(message: 'No comments yet');
                  }
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (_, index) {
                      final item = comments[index];
                      final picture = item.profilePicture;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: picture?.isNotEmpty == true
                              ? NetworkImage(AppConfig.mediaUrl(picture!))
                              : null,
                          child: picture?.isNotEmpty == true
                              ? null
                              : Text(
                                  item.username.isEmpty
                                      ? 'U'
                                      : item.username[0].toUpperCase(),
                                ),
                        ),
                        title: Text(item.username),
                        subtitle: Text(item.text),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Write a comment…',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
