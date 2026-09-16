import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_client.dart';
import '../../auth/auth_controller.dart';
import '../../core/app_router.dart';
import '../../models/feed_video.dart';
import '../../models/feed_ad.dart';
import '../../services/ad_service.dart';
import '../../services/feed_service.dart';
import '../../widgets/feed_video_card.dart';
import '../../widgets/feed_ad_card.dart';
import '../../widgets/app_states.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with RouteAware {
  bool _routeActive = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) AppRoutes.observer.subscribe(this, route);
  }

  @override
  void didPushNext() => setState(() => _routeActive = false);
  @override
  void didPopNext() => setState(() => _routeActive = true);
  @override
  void dispose() {
    AppRoutes.observer.unsubscribe(this);
    super.dispose();
  }

  late Future<List<FeedVideo>> _feed;
  late Future<_FeedAds> _ads;
  int _activeIndex = 0;
  @override
  void initState() {
    super.initState();
    _feed = FeedService().load();
    _ads = _loadAds();
  }

  Future<_FeedAds> _loadAds() async {
    try {
      final values = await Future.wait([
        AdService.instance.load('feed'),
        AdService.instance.load('feed'),
      ]);
      return _FeedAds(midRoll: values[0], betweenContent: values[1]);
    } catch (_) {
      return const _FeedAds();
    }
  }

  Future<void> _reload() async {
    final request = FeedService().load();
    final adsRequest = _loadAds();
    setState(() {
      _activeIndex = 0;
      _feed = request;
      _ads = adsRequest;
    });
    await request;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<List<FeedVideo>>(
      future: _feed,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppLoadingState(label: 'Loading feed…');
        }
        if (snapshot.hasError) {
          return AppErrorState(
            message: apiErrorMessage(snapshot.error!),
            onRetry: _reload,
          );
        }
        final videos = snapshot.data ?? const [];
        if (videos.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              children: const [
                SizedBox(height: 280),
                AppEmptyState(
                  message: 'No posts yet',
                  icon: Icons.video_library_outlined,
                ),
              ],
            ),
          );
        }
        return FutureBuilder<_FeedAds>(
          future: _ads,
          builder: (_, adSnapshot) {
            final entries = <Object>[];
            final adSet = adSnapshot.data ?? const _FeedAds();
            final ads = adSet.betweenContent;
            var adIndex = 0;
            for (var index = 0; index < videos.length; index++) {
              entries.add(videos[index]);
              if (index >= 2 &&
                  (index - 2) % 5 == 0 &&
                  index < videos.length - 1 &&
                  adIndex < ads.length) {
                entries.add(ads[adIndex++]);
              }
            }
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: entries.length,
              onPageChanged: (index) => setState(() => _activeIndex = index),
              itemBuilder: (_, index) {
                final entry = entries[index];
                if (entry is FeedAd) {
                  return FeedAdCard(
                    key: ValueKey('ad-${entry.id}'),
                    ad: entry,
                    isActive: _routeActive && index == _activeIndex,
                  );
                }
                final video = entry as FeedVideo;
                return FeedVideoCard(
                  key: ValueKey(video.id),
                  video: video,
                  isActive: _routeActive && index == _activeIndex,
                  midRollAd: () {
                    final videoIndex = videos.indexWhere(
                      (item) => item.id == video.id,
                    );
                    return videoIndex >= 0 && videoIndex < adSet.midRoll.length
                        ? adSet.midRoll[videoIndex]
                        : null;
                  }(),
                  onProfile: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.profile, arguments: video.userId),
                );
              },
            );
          },
        );
      },
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    floatingActionButton: Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.live),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black26,
            side: const BorderSide(color: Colors.white70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          icon: const Icon(Icons.live_tv, size: 18),
          label: const Text(
            'LIVE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const Spacer(),
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'For You',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 8)],
              ),
            ),
            SizedBox(height: 5),
            SizedBox(
              width: 26,
              child: Divider(height: 3, thickness: 3, color: Colors.white),
            ),
          ],
        ),
        const Spacer(),
        PopupMenuButton<String>(
          tooltip: 'Account and settings',
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onSelected: (value) {
            if ([
              AppRoutes.chat,
              AppRoutes.live,
              AppRoutes.wallet,
              AppRoutes.notifications,
            ].contains(value)) {
              Navigator.of(context).pushNamed(value);
            }
            if (value == 'profile') {
              final id = context.read<AuthController>().user!.id;
              Navigator.of(context).pushNamed(AppRoutes.profile, arguments: id);
            }
            if (value == 'logout') {
              context.read<AuthController>().logout();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: AppRoutes.chat, child: Text('Messages')),
            PopupMenuItem(value: AppRoutes.live, child: Text('Live')),
            PopupMenuItem(value: AppRoutes.wallet, child: Text('Wallet')),
            PopupMenuItem(
              value: AppRoutes.notifications,
              child: Text('Notifications'),
            ),
            PopupMenuItem(value: 'profile', child: Text('My profile')),
            PopupMenuItem(value: 'logout', child: Text('Log out')),
          ],
        ),
      ],
    ),
  );
}

class _FeedAds {
  const _FeedAds({this.midRoll = const [], this.betweenContent = const []});
  final List<FeedAd> midRoll;
  final List<FeedAd> betweenContent;
}
