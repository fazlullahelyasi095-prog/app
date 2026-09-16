import 'package:flutter/material.dart';

class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({super.key});

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  final TextEditingController _commentController = TextEditingController();

  bool isFollowing = false;
  bool isLiked = false;
  bool isPkActive = true;

  int likes = 24500;
  int viewers = 12800;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // =========================================================
          // LIVE VIDEO
          // =========================================================
          Positioned.fill(
            child: Container(
              color: const Color(0xff1b1b1b),
              child: const Center(
                child: Icon(Icons.videocam, color: Colors.white24, size: 90),
              ),
            ),
          ),

          // =========================================================
          // DARK GRADIENT
          // =========================================================
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black45,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0.0, 0.22, 0.65, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // =========================================================
          // MAIN LIVE UI
          // =========================================================
          SafeArea(
            child: Column(
              children: [
                // =====================================================
                // TOP PROFILE AREA
                // =====================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 6, 0),
                  child: Row(
                    children: [
                      // PROFILE IMAGE
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Color(0xff444444),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),

                      const SizedBox(width: 7),

                      // NAME + FOLLOW + VIEWERS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // USERNAME
                                const Flexible(
                                  child: Text(
                                    'Elyas Official',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 6),

                                // FOLLOW
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isFollowing = !isFollowing;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 26,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isFollowing
                                          ? Colors.white24
                                          : const Color(0xfffe2c55),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isFollowing ? 'Following' : 'Follow',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            Text(
                              '${_compactNumber(viewers)} viewers',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // VIEWER COUNT
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _compactNumber(viewers),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CLOSE
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // =====================================================
                // LIVE / RANK
                // =====================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
                  child: Row(
                    children: [
                      Container(
                        height: 23,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xfffe2c55),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      Container(
                        height: 23,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Daily Ranking #12',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // =====================================================
                // PK BATTLE
                // =====================================================
                if (isPkActive) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _pkBattle(),
                  ),
                ],

                const Spacer(),

                // =====================================================
                // COMMENTS + RIGHT BUTTONS
                // =====================================================
                SizedBox(
                  height: 220,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // COMMENTS
                      Expanded(
                        child: ListView(
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
                          children: const [
                            LiveComment(
                              username: 'Sara',
                              comment: 'Amazing live 🔥',
                            ),
                            LiveComment(
                              username: 'Ahmad',
                              comment: 'Hello from Kabul ❤️',
                            ),
                            LiveComment(
                              username: 'David',
                              comment: 'Great stream!',
                            ),
                            LiveComment(
                              username: 'Mina',
                              comment: 'Sent a Rose 🌹',
                              gift: true,
                            ),
                            LiveComment(
                              username: 'Alex',
                              comment: 'Lets win the PK!',
                            ),
                          ],
                        ),
                      ),

                      // RIGHT BUTTONS
                    ],
                  ),
                ),

                // =====================================================
                // BOTTOM COMMENT BAR
                // =====================================================
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    10,
                    5,
                    10,
                    MediaQuery.of(context).padding.bottom + 5,
                  ),
                  child: Row(
                    children: [
                      // COMMENT FIELD
                      Expanded(
                        child: Container(
                          height: 43,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.15),
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: TextField(
                            controller: _commentController,
                            textInputAction: TextInputAction.send,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Add comment...',
                              hintStyle: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white70,
                                size: 21,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) {
                              _sendComment();
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 7),

                      // SEND COMMENT
                      _bottomCircleButton(Icons.send, () {
                        _sendComment();
                      }),
                      SizedBox(width: 7),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.people),
                      ),

                      const SizedBox(width: 7),

                      // GIFT
                      _bottomCircleButton(Icons.card_giftcard, () {
                        _showGiftPanel(context);
                      }),

                      const SizedBox(width: 7),

                      // SHARE
                      Align(
                        alignment: Alignment.center,
                        child: _bottomCircleButton(Icons.reply_rounded, () {
                          // open share panel
                        }),
                      ),

                      // open share panel
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PK BATTLE
  // ===============================================================

  Widget _pkBattle() {
    return Column(
      children: [
        // SCORE / TIMER
        Row(
          children: [
            Expanded(
              child: Text(
                'Elyas   12,450',
                style: TextStyle(
                  color: Colors.pink.shade100,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.timer_outlined, size: 13, color: Colors.white),
                  SizedBox(width: 3),
                  Text(
                    '02:41',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Text(
                '9,830   Alex',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.blue.shade100,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // PK SCORE BAR
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                Expanded(
                  flex: 100,
                  child: Container(color: const Color(0xfffe2c55)),
                ),

                Expanded(
                  flex: 44,
                  child: Container(color: const Color(0xff25f4ee)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // RIGHT BUTTON
  // ===============================================================

  Widget_rightButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 25),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BOTTOM CIRCLE BUTTON
  // ===============================================================

  Widget _bottomCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

  // ===============================================================
  // SEND COMMENT
  // ===============================================================

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    _commentController.clear();

    FocusScope.of(context).unfocus();
  }

  // ===============================================================
  // GIFT PANEL
  // ===============================================================

  void _showGiftPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff171717),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: 370,
            child: Column(
              children: [
                // TOP
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      const Text(
                        'Send Gift',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.amber,
                        size: 19,
                      ),

                      const SizedBox(width: 5),

                      const Text(
                        '2,450',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 5),

                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 12,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Colors.white12),

                // GIFTS
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(10),
                    crossAxisCount: 4,
                    childAspectRatio: .82,
                    children: const [
                      GiftItem(emoji: '🌹', name: 'Rose', coins: '1'),

                      GiftItem(emoji: '❤️', name: 'Heart', coins: '5'),

                      GiftItem(emoji: '🎁', name: 'Gift', coins: '20'),

                      GiftItem(emoji: '🔥', name: 'Fire', coins: '50'),

                      GiftItem(emoji: '💎', name: 'Diamond', coins: '100'),

                      GiftItem(emoji: '👑', name: 'Crown', coins: '500'),

                      GiftItem(emoji: '🚗', name: 'Car', coins: '1000'),

                      GiftItem(emoji: '🚀', name: 'Rocket', coins: '5000'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // NUMBER FORMAT
  // ===============================================================

  String _compactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }

    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    return number.toString();
  }
}

// =================================================================
// LIVE COMMENT
// =================================================================

class LiveComment extends StatelessWidget {
  final String username;
  final String comment;
  final bool gift;

  const LiveComment({
    super.key,
    required this.username,
    required this.comment,
    this.gift = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$username  ',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              TextSpan(
                text: comment,
                style: TextStyle(
                  color: gift ? Colors.amber.shade200 : Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// GIFT ITEM
// =================================================================

class GiftItem extends StatelessWidget {
  final String emoji;
  final String name;
  final String coins;

  const GiftItem({
    super.key,
    required this.emoji,
    required this.name,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),

          const SizedBox(height: 5),

          Text(name, style: const TextStyle(color: Colors.white, fontSize: 11)),

          const SizedBox(height: 3),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 13),

              const SizedBox(width: 2),

              Text(
                coins,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
