import 'package:flutter/material.dart';

class LiveCenterPage extends StatelessWidget {
  const LiveCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'LIVE Center',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          children: [
            // LIVE STATUS CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2C55).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.live_tv_rounded,
                          color: Color(0xFFFF2C55),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your LIVE Center',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage your LIVE activity, guests, PK, gifts and performance.',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Open Start LIVE page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2C55),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.videocam_rounded, size: 21),
                      label: const Text(
                        'Go LIVE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QUICK STATS
            Row(
              children: [
                Expanded(
                  child: statCard(
                    icon: Icons.visibility_outlined,
                    value: '12.4K',
                    label: 'Viewers',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: statCard(
                    icon: Icons.favorite_border_rounded,
                    value: '8.2K',
                    label: 'Likes',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: statCard(
                    icon: Icons.card_giftcard_rounded,
                    value: '1.3K',
                    label: 'Gifts',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            sectionTitle('LIVE management'),

            liveItem(
              icon: Icons.history_rounded,
              title: 'LIVE History',
              subtitle: 'View your previous LIVE sessions',
              onTap: () {
                // Open live history
              },
            ),

            liveItem(
              icon: Icons.analytics_outlined,
              title: 'LIVE Analytics',
              subtitle: 'Viewers, watch time, likes and engagement',
              onTap: () {
                // Open live analytics
              },
            ),

            liveItem(
              icon: Icons.people_alt_outlined,
              title: 'Guests & Co-hosts',
              subtitle: 'Manage guest invitations and co-hosts',
              onTap: () {
                // Open guests page
              },
            ),

            liveItem(
              icon: Icons.sports_kabaddi_outlined,
              title: 'PK Battles',
              subtitle: 'Manage PK matches and battle history',
              onTap: () {
                // Open PK page
              },
            ),

            const SizedBox(height: 14),

            sectionTitle('Rewards & earnings'),

            liveItem(
              icon: Icons.card_giftcard_rounded,
              title: 'LIVE Gifts',
              subtitle: 'See gifts received during your LIVE',
              onTap: () {
                // Open live gifts
              },
            ),

            liveItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'LIVE Earnings',
              subtitle: 'View LIVE rewards and earnings',
              onTap: () {
                // Open live earnings
              },
            ),

            liveItem(
              icon: Icons.emoji_events_outlined,
              title: 'LIVE Rewards',
              subtitle: 'View LIVE rewards and milestones',
              onTap: () {
                // Open live rewards
              },
            ),

            const SizedBox(height: 14),

            sectionTitle('Safety & settings'),

            liveItem(
              icon: Icons.shield_outlined,
              title: 'LIVE Safety',
              subtitle: 'Comment filters, moderators and blocked users',
              onTap: () {
                // Open live safety
              },
            ),

            liveItem(
              icon: Icons.settings_outlined,
              title: 'LIVE Settings',
              subtitle: 'Manage camera, microphone and LIVE preferences',
              onTap: () {
                // Open live settings
              },
            ),

            liveItem(
              icon: Icons.help_outline_rounded,
              title: 'LIVE Help',
              subtitle: 'Rules, eligibility and LIVE support',
              onTap: () {
                // Open live help
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF2C55), size: 23),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static Widget liveItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),

        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white24,
          size: 15,
        ),
      ),
    );
  }
}
