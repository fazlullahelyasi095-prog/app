import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../api/api_client.dart';
import '../../services/upload_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const maxBytes = 2 * 1024 * 1024 * 1024;
  final _caption = TextEditingController();
  XFile? _media;
  VideoPlayerController? _preview;
  bool _submitting = false;
  double? _progress;
  String? _error;

  bool get _isImage {
    final name = _media?.name.toLowerCase() ?? '';
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp');
  }

  Future<void> _pick() async {
    final selected = await ImagePicker().pickMedia();
    if (selected == null) return;
    final size = await selected.length();
    if (size > maxBytes) {
      setState(() => _error = 'Media file must be 2 GB or smaller.');
      return;
    }
    await _preview?.dispose();
    VideoPlayerController? preview;
    final lower = selected.name.toLowerCase();
    final isImage =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
    if (!isImage) {
      preview = VideoPlayerController.file(File(selected.path));
      try {
        await preview.initialize();
      } catch (_) {
        await preview.dispose();
        preview = null;
      }
    }
    if (mounted) {
      setState(() {
        _media = selected;
        _preview = preview;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final media = _media;
    if (media == null) {
      setState(() => _error = 'Choose an image or video.');
      return;
    }
    setState(() {
      _submitting = true;
      _progress = 0;
      _error = null;
    });
    try {
      await UploadService().createPost(
        media,
        _caption.text,
        onProgress: (sent, total) {
          if (mounted && total > 0) setState(() => _progress = sent / total);
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully.')),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    _preview?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create post')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OutlinedButton.icon(
            onPressed: _submitting ? null : _pick,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              _media == null
                  ? 'Choose image or video'
                  : 'Choose different media',
            ),
          ),
          if (_media != null) ...[
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isImage
                    ? Image.file(File(_media!.path), fit: BoxFit.contain)
                    : _preview?.value.isInitialized == true
                    ? VideoPlayer(_preview!)
                    : const Center(child: Text('Video preview unavailable')),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _caption,
            maxLength: 2000,
            maxLines: 4,
            enabled: !_submitting,
            decoration: const InputDecoration(labelText: 'Caption'),
          ),
          if (_progress != null) LinearProgressIndicator(value: _progress),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Uploading…' : 'Upload'),
          ),
        ],
      ),
    ),
  );
}
