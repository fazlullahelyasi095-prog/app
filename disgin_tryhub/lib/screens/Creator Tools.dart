import 'package:flutter/material.dart';

class CreatorToolsPage extends StatelessWidget {
  const CreatorToolsPage({super.key});

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
          'Creator Tools',
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
            // Creator summary card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2C55).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
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
                          'Grow your creator account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Manage your content, analytics, LIVE, earnings and creator settings.',
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
            ),

            const SizedBox(height: 22),

            sectionTitle('Overview'),

            creatorToolItem(
              icon: Icons.analytics_outlined,
              title: 'Analytics',
              subtitle: 'Views, followers, likes and engagement',
              onTap: () {
                // Open Analytics page
              },
            ),

            creatorToolItem(
              icon: Icons.insights_rounded,
              title: 'Creator Dashboard',
              subtitle: 'See account performance and growth',
              onTap: () {
                // Open Creator Dashboard
              },
            ),

            const SizedBox(height: 14),

            sectionTitle('Content'),

            creatorToolItem(
              icon: Icons.video_library_outlined,
              title: 'Manage Videos',
              subtitle: 'Manage published, private and draft videos',
              onTap: () {
                // Open video manager
              },
            ),

            creatorToolItem(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Creator Inspiration',
              subtitle: 'Ideas and trends for new content',
              onTap: () {
                // Open inspiration page
              },
            ),

            creatorToolItem(
              icon: Icons.calendar_month_outlined,
              title: 'Content Scheduler',
              subtitle: 'Schedule videos for publishing',
              onTap: () {
                // Open scheduler
              },
            ),

            const SizedBox(height: 14),

            sectionTitle('LIVE'),

            creatorToolItem(
              icon: Icons.live_tv_rounded,
              title: 'LIVE Center',
              subtitle: 'Manage LIVE settings and history',
              onTap: () {
                // Open LIVE center
              },
            ),

            creatorToolItem(
              icon: Icons.groups_2_outlined,
              title: 'LIVE Guests & PK',
              subtitle: 'Manage guests, co-hosts and PK battles',
              onTap: () {
                // Open LIVE guest / PK page
              },
            ),

            creatorToolItem(
              icon: Icons.card_giftcard_rounded,
              title: 'LIVE Gifts',
              subtitle: 'View gifts received during LIVE',
              onTap: () {
                // Open live gifts page
              },
            ),

            const SizedBox(height: 14),

            sectionTitle('Earnings'),

            creatorToolItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Creator Earnings',
              subtitle: 'View creator rewards and earnings',
              onTap: () {
                // Open earnings page
              },
            ),

            creatorToolItem(
              icon: Icons.monetization_on_outlined,
              title: 'Monetization',
              subtitle: 'Manage eligible monetization features',
              onTap: () {
                // Open monetization page
              },
            ),

            creatorToolItem(
              icon: Icons.receipt_long_outlined,
              title: 'Transactions',
              subtitle: 'View creator payment history',
              onTap: () {
                // Open transaction page
              },
            ),

            const SizedBox(height: 14),

            sectionTitle('Creator account'),

            creatorToolItem(
              icon: Icons.verified_outlined,
              title: 'Creator Verification',
              subtitle: 'Verification status and requirements',
              onTap: () {
                // Open verification page
              },
            ),

            creatorToolItem(
              icon: Icons.campaign_outlined,
              title: 'Promote',
              subtitle: 'Promote your content to reach more people',
              onTap: () {
                // Open Promote page
              },
            ),

            creatorToolItem(
              icon: Icons.settings_outlined,
              title: 'Creator Settings',
              subtitle: 'Manage creator preferences and permissions',
              onTap: () {
                // Open creator settings
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

  static Widget creatorToolItem({
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
