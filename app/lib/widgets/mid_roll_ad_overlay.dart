import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../core/app_config.dart';
import '../models/feed_ad.dart';
import '../services/ad_service.dart';

class MidRollAdOverlay extends StatefulWidget {
  const MidRollAdOverlay({
    super.key,
    required this.ad,
    required this.onFinished,
  });
  final FeedAd ad;
  final VoidCallback onFinished;
  @override
  State<MidRollAdOverlay> createState() => _MidRollAdOverlayState();
}

class _MidRollAdOverlayState extends State<MidRollAdOverlay> {
  VideoPlayerController? _video;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await AdService.instance.impression(widget.ad.deliveryToken);
    } catch (_) {}
    if (widget.ad.video?.isNotEmpty == true) {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(AppConfig.mediaUrl(widget.ad.video!)),
      );
      try {
        await controller.initialize();
        controller.addListener(_watchVideo);
        if (mounted) setState(() => _video = controller);
        await controller.play();
      } catch (_) {
        await controller.dispose();
        widget.onFinished();
      }
    } else {
      _timer = Timer(const Duration(seconds: 5), widget.onFinished);
    }
  }

  void _watchVideo() {
    final value = _video?.value;
    if (value != null &&
        value.isInitialized &&
        value.position >= value.duration &&
        !value.isPlaying) {
      widget.onFinished();
    }
  }

  Future<void> _open() async {
    try {
      await AdService.instance.click(widget.ad.deliveryToken);
      final destination = widget.ad.destinationUrl;
      if (destination != null && destination.isNotEmpty) {
        await launchUrl(
          Uri.parse(destination),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _video?.removeListener(_watchVideo);
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black,
    child: SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_video?.value.isInitialized == true)
            Center(
              child: AspectRatio(
                aspectRatio: _video!.value.aspectRatio,
                child: VideoPlayer(_video!),
              ),
            )
          else if (widget.ad.image?.isNotEmpty == true)
            Image.network(
              AppConfig.mediaUrl(widget.ad.image!),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            )
          else
            const Center(child: CircularProgressIndicator()),
          const Positioned(
            top: 12,
            left: 12,
            child: Chip(label: Text('Sponsored')),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ad.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (widget.ad.destinationUrl?.isNotEmpty == true)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _open,
                      child: Text(widget.ad.callToAction),
                    ),
                  ),
                TextButton(
                  onPressed: widget.onFinished,
                  child: const Text('Close ad'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
