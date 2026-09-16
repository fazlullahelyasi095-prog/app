import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/api_client.dart';
import '../../auth/auth_controller.dart';
import '../../core/app_config.dart';
import '../../core/app_router.dart';
import '../../core/app_theme.dart';
import '../../models/feed_video.dart';
import '../../services/profile_service.dart';
import '../../services/ad_service.dart';
import '../../models/feed_ad.dart';
import '../../services/social_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/app_states.dart';
import '../../widgets/report_dialog.dart';
import '../../widgets/feed_ad_card.dart';
import '../../chat/chat_screen.dart';
import '../../services/chat_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userId});
  final int userId;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profile;
  bool? _following;
  BlockStatus? _blockStatus;
  bool _followBusy = false;
  bool _blockBusy = false;
  bool _pictureBusy = false;
  List<FeedAd> _profileAds = const [];
  @override
  void initState() {
    super.initState();
    _profile = _loadProfile();
    _loadFollow();
    _loadBlock();
  }

  Future<UserProfile> _loadProfile() async {
    final profile = await ProfileService().load(widget.userId);
    if (profile.user.followers > 1000) {
      try {
        _profileAds = await AdService.instance.load('between_content');
      } catch (_) {
        _profileAds = const [];
      }
    } else {
      _profileAds = const [];
    }
    return profile;
  }

  Future<void> _loadBlock() async {
    try {
      final value = await SocialService().blockStatus(widget.userId);
      if (mounted) setState(() => _blockStatus = value);
    } catch (_) {}
  }

  Future<void> _loadFollow() async {
    try {
      final value = await ProfileService().followStatus(widget.userId);
      if (mounted) setState(() => _following = value);
    } catch (_) {}
  }

  Future<void> _toggleFollow() async {
    if (_followBusy) return;
    setState(() => _followBusy = true);
    try {
      final value = await ProfileService().toggleFollow(widget.userId);
      if (mounted) {
        setState(() {
          _following = value;
          _profile = _loadProfile();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  Future<void> _toggleBlock() async {
    if (_blockBusy || _blockStatus == null) return;
    final blocked = _blockStatus!.isBlocked;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(blocked ? 'Unblock user?' : 'Block user?'),
        content: Text(
          blocked
              ? 'This user will be able to interact with you again.'
              : 'Blocking also removes follow relationships between you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(blocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _blockBusy = true);
    try {
      final value = await SocialService().toggleBlock(widget.userId, blocked);
      if (mounted) {
        setState(() {
          _blockStatus = BlockStatus(
            isBlocked: value,
            isBlockedBy: _blockStatus!.isBlockedBy,
          );
          if (value) _following = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _blockBusy = false);
    }
  }

  Future<void> _changePicture() async {
    if (_pictureBusy) return;
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final extension = image.name.toLowerCase();
    if (!(extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.webp'))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose a JPEG, PNG, or WebP image.')),
        );
      }
      return;
    }
    if (await image.length() > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture must be 5 MB or smaller.'),
          ),
        );
      }
      return;
    }
    setState(() => _pictureBusy = true);
    try {
      await UploadService().updateProfilePicture(image);
      if (mounted) {
        setState(() {
          _profile = _loadProfile();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _pictureBusy = false);
    }
  }

  Future<void> _deletePost(int videoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await UploadService().deletePost(videoId);
      if (mounted) {
        setState(() {
          _profile = _loadProfile();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }

  void _openMenu() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close menu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
      pageBuilder: (sheetContext, _, _) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * .78,
          height: double.infinity,
          child: Theme(
            data: AppTheme.light,
            child: Material(
              color: Colors.white,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Close menu',
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                            ),
                          ),
                          const Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      for (final entry in const [
                        (
                          Icons.account_balance_wallet_outlined,
                          'Balance',
                          AppRoutes.wallet,
                        ),
                        (
                          Icons.notifications_outlined,
                          'Notifications',
                          AppRoutes.notifications,
                        ),
                        (Icons.inbox_outlined, 'Inbox', AppRoutes.chat),
                        (Icons.live_tv, 'Live', AppRoutes.live),
                      ])
                        ListTile(
                          leading: Icon(entry.$1),
                          title: Text(entry.$2),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.of(context).pushNamed(entry.$3);
                          },
                        ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Log out'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.read<AuthController>().logout();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _postGrid(UserProfile profile, bool isMe) {
    final sections = <Widget>[];
    var pending = <FeedVideo>[];
    void flush() {
      if (pending.isEmpty) return;
      final posts = List<FeedVideo>.of(pending);
      pending = [];
      sections.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: .72,
          ),
          itemBuilder: (_, index) {
            final post = posts[index];
            return Semantics(
              label:
                  '${post.caption.isEmpty ? 'Untitled post' : post.caption}, ${post.likes} likes, ${post.comments} comments',
              child: Container(
                color: const Color(0xff191919),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white24,
                        size: 42,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        tooltip: isMe ? 'Delete post' : 'Report post',
                        onPressed: isMe
                            ? () => _deletePost(post.id)
                            : () => showReportDialog(
                                context,
                                targetType: 'Post',
                                targetId: post.id,
                              ),
                        icon: Icon(
                          isMe ? Icons.delete_outline : Icons.flag_outlined,
                          size: 19,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 7,
                      right: 7,
                      bottom: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.caption.isEmpty
                                ? 'Untitled post'
                                : post.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${post.likes} likes · ${post.comments} comments',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    for (var index = 0; index < profile.videos.length; index++) {
      pending.add(profile.videos[index]);
      // Keep existing profile-ad order and eligibility intact.
      if (index < profile.videos.length - 1 && index < _profileAds.length) {
        flush();
        sections.add(
          SizedBox(
            height: 520,
            child: FeedAdCard(ad: _profileAds[index], isActive: true),
          ),
        );
      }
    }
    flush();
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final isMe = context.read<AuthController>().user?.id == widget.userId;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<UserProfile>(
          future: _profile,
          builder: (_, snapshot) => Text(
            snapshot.hasData ? '@${snapshot.data!.user.username}' : 'Profile',
          ),
        ),
        actions: [
          if (isMe)
            IconButton(
              tooltip: 'Menu',
              onPressed: _openMenu,
              icon: const Icon(Icons.menu, size: 28),
            ),
          if (!isMe)
            IconButton(
              tooltip: 'Message',
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () async {
                try {
                  final id = await ChatService().start(widget.userId);
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(conversationId: id),
                    ),
                  );
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(apiErrorMessage(error))),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _profile,
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingState(label: 'Loading profile…');
          }
          if (snapshot.hasError) {
            return AppErrorState(
              message: apiErrorMessage(snapshot.error!),
              onRetry: () => setState(() {
                _profile = _loadProfile();
              }),
            );
          }
          final profile = snapshot.data!;
          final picture = profile.user.profilePicture;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _profile = _loadProfile();
              });
              await _profile;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 15, bottom: 20),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: isMe ? _changePicture : null,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: picture == null || picture.isEmpty
                          ? null
                          : NetworkImage(AppConfig.mediaUrl(picture)),
                      child: _pictureBusy
                          ? const CircularProgressIndicator()
                          : picture == null || picture.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 58,
                              color: Colors.black,
                            )
                          : null,
                    ),
                  ),
                ),
                if (isMe)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _pictureBusy ? null : _changePicture,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: const Text('Change photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  '@${profile.user.username}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _Stat('${profile.user.following}', 'Following'),
                    ),
                    Expanded(
                      child: _Stat('${profile.user.followers}', 'Followers'),
                    ),
                    Expanded(
                      child: _Stat(
                        '${profile.videos.fold<int>(0, (total, post) => total + post.likes)}',
                        'Likes',
                      ),
                    ),
                  ],
                ),
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: FilledButton(
                      onPressed:
                          _following == null ||
                              _followBusy ||
                              _blockStatus?.isBlocked == true ||
                              _blockStatus?.isBlockedBy == true
                          ? null
                          : _toggleFollow,
                      child: Text(_following == true ? 'Following' : 'Follow'),
                    ),
                  ),
                if (!isMe)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _blockBusy || _blockStatus == null
                            ? null
                            : _toggleBlock,
                        child: Text(
                          _blockStatus?.isBlocked == true ? 'Unblock' : 'Block',
                        ),
                      ),
                      TextButton(
                        onPressed: () => showReportDialog(
                          context,
                          targetType: 'User',
                          targetId: widget.userId,
                        ),
                        child: const Text('Report'),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.grid_on, size: 23),
                      const SizedBox(width: 8),
                      Text('${profile.videos.length} posts'),
                    ],
                  ),
                ),
                const Divider(height: 2, color: Colors.white),
                if (profile.videos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: AppEmptyState(
                      message: 'No posts yet',
                      icon: Icons.video_library_outlined,
                    ),
                  ),
                ..._postGrid(profile, isMe),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    ],
  );
}
