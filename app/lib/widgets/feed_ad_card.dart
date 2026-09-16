import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../core/app_config.dart';
import '../models/feed_ad.dart';
import '../services/ad_service.dart';

class FeedAdCard extends StatefulWidget {
  const FeedAdCard({super.key, required this.ad, required this.isActive});
  final FeedAd ad;
  final bool isActive;
  @override
  State<FeedAdCard> createState() => _FeedAdCardState();
}

class _FeedAdCardState extends State<FeedAdCard> with WidgetsBindingObserver {
  VideoPlayerController? _video;
  bool _impressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepare();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive) {
      _video?.play();
    } else {
      _video?.pause();
    }
  }

  Future<void> _prepare() async {
    if (widget.ad.video?.isNotEmpty == true) {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(AppConfig.mediaUrl(widget.ad.video!)),
      );
      try {
        await controller.initialize();
        await controller.setLooping(true);
        if (mounted) {
          setState(() => _video = controller);
        } else {
          await controller.dispose();
        }
      } catch (_) {
        await controller.dispose();
      }
    }
    _sync();
  }

  @override
  void didUpdateWidget(covariant FeedAdCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) _sync();
  }

  Future<void> _sync() async {
    if (widget.isActive) {
      if (!_impressed) {
        _impressed = true;
        try {
          await AdService.instance.impression(widget.ad.deliveryToken);
        } catch (_) {}
      }
      await _video?.play();
    } else {
      await _video?.pause();
    }
  }

  Future<void> _open() async {
    try {
      if (!_impressed) {
        await AdService.instance.impression(widget.ad.deliveryToken);
        _impressed = true;
      }
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
    WidgetsBinding.instance.removeObserver(this);
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xff111116),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Chip(label: Text('Sponsored')),
                const Spacer(),
                Text(widget.ad.campaignName),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _video?.value.isInitialized == true
                    ? AspectRatio(
                        aspectRatio: _video!.value.aspectRatio,
                        child: VideoPlayer(_video!),
                      )
                    : widget.ad.image?.isNotEmpty == true
                    ? Image.network(
                        AppConfig.mediaUrl(widget.ad.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.campaign_outlined, size: 80),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.ad.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (widget.ad.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(widget.ad.description),
              ),
            if (widget.ad.destinationUrl?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _open,
                    child: Text(widget.ad.callToAction),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
