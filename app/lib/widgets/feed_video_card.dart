import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../api/api_client.dart';
import '../core/app_config.dart';
import '../models/feed_video.dart';
import '../models/feed_ad.dart';
import '../screens/comments/comments_sheet.dart';
import '../services/social_service.dart';
import 'report_dialog.dart';
import 'mid_roll_ad_overlay.dart';

class FeedVideoCard extends StatefulWidget {
  const FeedVideoCard({
    super.key,
    required this.video,
    required this.onProfile,
    required this.isActive,
    this.midRollAd,
  });
  final FeedVideo video;
  final VoidCallback onProfile;
  final bool isActive;
  final FeedAd? midRollAd;
  @override
  State<FeedVideoCard> createState() => _FeedVideoCardState();
}

class _FeedVideoCardState extends State<FeedVideoCard>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Object? _error;
  bool _userPaused = false;
  bool _appIsActive = true;
  bool? _isLiked;
  bool _likeBusy = false;
  late int _likes;
  late int _comments;
  bool _midRollShown = false;
  bool _midRollActive = false;

  bool get _isImage {
    final path = widget.video.url.toLowerCase().split('?').first;
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp');
  }

  @override
  void initState() {
    super.initState();
    _likes = widget.video.likes;
    _comments = widget.video.comments;
    WidgetsBinding.instance.addObserver(this);
    if (!_isImage) _initialize();
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    try {
      final value = await SocialService().likeStatus(widget.video.id);
      if (mounted) setState(() => _isLiked = value);
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    if (_likeBusy) return;
    setState(() => _likeBusy = true);
    try {
      final liked = await SocialService().toggleLike(widget.video.id);
      // A successful like must remain visible even if the count refresh fails.
      if (mounted) {
        setState(() {
          if (_isLiked != liked)
            _likes = (_likes + (liked ? 1 : -1)).clamp(0, 1 << 31);
          _isLiked = liked;
        });
      }
      final count = await SocialService().likeCount(widget.video.id);
      if (mounted) {
        setState(() {
          _isLiked = liked;
          _likes = count;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  Future<void> _openComments() async {
    await _controller?.pause();
    if (!mounted) return;
    await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CommentsSheet(
        videoId: widget.video.id,
        onAdded: () {
          if (mounted) setState(() => _comments++);
        },
      ),
    );
    await _syncPlayback();
  }

  Future<void> _initialize() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(AppConfig.mediaUrl(widget.video.url)),
      );
      await controller.initialize();
      controller.addListener(_checkMidRoll);
      await controller.setLooping(true);
      if (widget.isActive && _appIsActive) await controller.play();
      if (mounted) {
        setState(() => _controller = controller);
      } else {
        controller.dispose();
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  void _checkMidRoll() {
    final controller = _controller;
    if (_midRollShown ||
        widget.midRollAd == null ||
        controller == null ||
        !controller.value.isInitialized ||
        controller.value.duration <= const Duration(seconds: 60) ||
        controller.value.position < const Duration(seconds: 60)) {
      return;
    }
    _midRollShown = true;
    _midRollActive = true;
    controller.pause();
    if (mounted) setState(() {});
  }

  void _finishMidRoll() {
    if (!mounted || !_midRollActive) return;
    setState(() => _midRollActive = false);
    _syncPlayback();
  }

  @override
  void didUpdateWidget(covariant FeedVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncPlayback();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsActive = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      _syncPlayback();
    } else {
      _controller?.pause();
    }
  }

  Future<void> _syncPlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (widget.isActive && _appIsActive && !_userPaused) {
      await controller.play();
    } else {
      await controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_checkMidRoll);
    _controller?.dispose();
    super.dispose();
  }

  void _toggle() {
    final controller = _controller;
    if (controller == null) return;
    _userPaused = controller.value.isPlaying;
    controller.value.isPlaying ? controller.pause() : controller.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      GestureDetector(
        onTap: _toggle,
        onDoubleTap: () {
          if (_isLiked != true) _toggleLike();
        },
        child: ColoredBox(
          color: Colors.black,
          child: Center(
            child: _isImage
                ? Image.network(
                    AppConfig.mediaUrl(widget.video.url),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined, size: 56),
                  )
                : _error != null
                ? const Icon(Icons.broken_image_outlined, size: 56)
                : _controller == null
                ? const CircularProgressIndicator()
                : SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
          ),
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
                  Colors.black38,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black87,
                ],
                stops: [0, .2, .55, 1],
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 16,
        right: 84,
        bottom: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onProfile,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        widget.video.profilePicture?.isNotEmpty == true
                        ? NetworkImage(
                            AppConfig.mediaUrl(widget.video.profilePicture!),
                          )
                        : null,
                    child: widget.video.profilePicture?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '@${widget.video.username}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.video.caption),
          ],
        ),
      ),
      Positioned(
        right: 12,
        bottom: 48,
        child: Column(
          children: [
            IconButton(
              onPressed: widget.onProfile,
              tooltip: 'View profile',
              icon: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: widget.video.profilePicture?.isNotEmpty == true
                    ? NetworkImage(
                        AppConfig.mediaUrl(widget.video.profilePicture!),
                      )
                    : null,
                child: widget.video.profilePicture?.isNotEmpty == true
                    ? null
                    : const Icon(Icons.person, size: 30, color: Colors.black),
              ),
            ),
            IconButton(
              tooltip: _isLiked == true ? 'Unlike post' : 'Like post',
              onPressed: _likeBusy ? null : _toggleLike,
              icon: Icon(
                Icons.favorite,
                size: 35,
                color: _isLiked == true
                    ? const Color(0xfffe2c55)
                    : Colors.white,
              ),
            ),
            Text('$_likes'),
            const SizedBox(height: 14),
            IconButton(
              tooltip: 'Open comments',
              onPressed: _openComments,
              icon: const Icon(Icons.chat_bubble, size: 32),
            ),
            Text('$_comments'),
            const SizedBox(height: 10),
            IconButton(
              onPressed: () => showReportDialog(
                context,
                targetType: 'Post',
                targetId: widget.video.id,
              ),
              icon: const Icon(Icons.flag_outlined),
            ),
          ],
        ),
      ),
      if (_midRollActive && widget.midRollAd != null)
        MidRollAdOverlay(ad: widget.midRollAd!, onFinished: _finishMidRoll),
    ],
  );
}
