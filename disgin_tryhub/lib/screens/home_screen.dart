import 'package:flutter/material.dart';

import 'live_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTopTab = 2;

  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> videos = [
    {
      'username': 'elyasi',
      'caption': 'Welcome to TryHub 🔥',
      'music': 'Original Sound ',
      'likes': 24500,
      'comments': 1240,
      'shares': 345,

      'liked': false,
      'following': false,
    },
    {
      'username': 'tryhub_live',
      'caption': 'New video on TryHub ❤️',
      'music': 'Music',
      'likes': 18200,
      'comments': 890,
      'shares': 210,

      'liked': false,
      'following': true,
    },
    {
      'username': 'creator_one',
      'caption': 'Enjoy this video ✨',
      'music': 'Original Audio',
      'likes': 48000,
      'comments': 4300,
      'shares': 920,

      'liked': false,
      'following': false,
    },
  ];

  void toggleLike(int index) {
    setState(() {
      bool liked = videos[index]['liked'];

      videos[index]['liked'] = !liked;

      if (!liked) {
        videos[index]['likes']++;
      } else {
        videos[index]['likes']--;
      }
    });
  }

  void toggleFollow(int index) {
    setState(() {
      videos[index]['following'] = !videos[index]['following'];
    });
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }

    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    return '$number';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // ===============================
          // VIDEO FEED
          // ===============================

          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return buildVideoPage(index);
            },
          ),

          // ===============================
          // TOP MENU
          // ===============================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 20),
              child: Row(
                children: [
                  // LIVE

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LiveRoomPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white70),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.live_tv, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  buildTopTab(title: 'Local', index: 1),

                  const SizedBox(width: 18),

                  buildTopTab(title: 'Following', index: 2),

                  const SizedBox(width: 18),

                  buildTopTab(title: 'For You', index: 3),

                  const Spacer(),

                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.search_sharp,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // TOP TAB
  // ===================================================

  Widget buildTopTab({required String title, required int index}) {
    bool selected = selectedTopTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTopTab = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white60,
              fontSize: selected ? 16 : 15,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          const SizedBox(height: 4),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: selected ? 24 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // VIDEO PAGE
  // ===================================================

  Widget buildVideoPage(int index) {
    final video = videos[index];

    return Stack(
      children: [
        // ===============================================
        // VIDEO PLACEHOLDER
        // ===============================================

        Positioned.fill(
          child: Container(
            color: index % 2 == 0 ? Colors.grey.shade900 : Colors.black87,

            child: const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 85,
                color: Colors.white24,
              ),
            ),
          ),
        ),

        // ===============================================
        // VIDEO DARK GRADIENT
        // ===============================================
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black87,
                ],
              ),
            ),
          ),
        ),

        // ===============================================
        // RIGHT BUTTONS
        // ===============================================
        Positioned(
          right: 20,
          bottom: 1,
          child: Column(
            children: [
              // PROFILE

              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  GestureDetector(
                    onTap: () {
                      debugPrint('Open ${video['username']} profile');
                    },
                    child: const CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xff333333),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -11,
                    child: GestureDetector(
                      onTap: () {
                        toggleFollow(index);
                      },
                      child: Container(
                        width: 23,
                        height: 23,
                        decoration: BoxDecoration(
                          color: video['following']
                              ? Colors.white
                              : const Color(0xfffe2c55),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          video['following'] ? Icons.check : Icons.add,
                          size: 17,
                          color: video['following']
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // LIKE
              GestureDetector(
                onTap: () {
                  toggleLike(index);
                },
                child: Icon(
                  Icons.favorite,
                  size: 25,
                  color: video['liked']
                      ? const Color(0xfffe2c55)
                      : Colors.white,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                formatNumber(video['likes']),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              // COMMENT
              GestureDetector(
                onTap: () {
                  showComments(context);
                },
                child: const Icon(Icons.chat, size: 25, color: Colors.white),
              ),

              const SizedBox(height: 10),

              Text(
                formatNumber(video['comments']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                formatNumber(video['saves'] ?? 0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),

              GestureDetector(
                onTap: () {
                  showGiftPanel(context);
                },
                child: const Icon(
                  Icons.bookmark_border,
                  size: 35,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // SHARE
              GestureDetector(
                onTap: () {
                  showSharePanel(context);
                },
                child: Transform.flip(
                  flipX: true,
                  child: Icon(
                    Icons.reply_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              Text(
                formatNumber(video['shares']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // MUSIC DISC
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 5),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ],
          ),
        ),

        // ===============================================
        // VIDEO USER INFORMATION
        // ===============================================
        Positioned(
          left: 15,
          right: 80,
          bottom: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${video['username']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                video['caption'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 17),

                  const SizedBox(width: 5),

                  Expanded(
                    child: Text(
                      video['music'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================================================
  // COMMENTS
  // ===================================================

  void showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              const SizedBox(height: 12),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Comments',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const Divider(),

              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        'User ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Nice video 🔥'),
                      trailing: const Icon(Icons.favorite_border),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add comment...',
                    suffixIcon: const Icon(Icons.send),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================================================
  // GIFT PANEL
  // ===================================================

  void showGiftPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Send Gift',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: 8,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const Text('🎁', style: TextStyle(fontSize: 35)),
                        Text(
                          '${index + 1} Coin',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================================================
  // SHARE
  // ===================================================

  void showSharePanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 230,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Share to',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  shareButton(Icons.abc_rounded, 'tryhub'),

                  shareButton(Icons.copy, 'Copy Link'),

                  shareButton(Icons.message, 'Message'),

                  shareButton(Icons.download, 'Save'),

                  shareButton(Icons.more_horiz, 'More'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget shareButton(IconData icon, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.black),
        ),

        const SizedBox(height: 7),

        Text(title, style: const TextStyle(color: Colors.black, fontSize: 11)),
      ],
    );
  }
}
