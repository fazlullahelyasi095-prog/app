import 'package:disgin_tryhub/screens/Account_screen.dart';
import 'package:disgin_tryhub/screens/Creator%20Tools.dart';
import 'package:flutter/material.dart';

import 'package:disgin_tryhub/screens/balance_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromARGB(255, 0, 0, 0),
            size: 20,
          ),
        ),

        title: const Text(
          'Menu',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PROFILE CARD
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 0, 0, 0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 248, 246, 246),
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TryHub User',

                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '@tryhub_user',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              sectionTitle('Account'),

              const SizedBox(height: 10),

              menuBox(
                children: [
                  menuItem(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Balance',
                    subtitle: 'Coins, rewards and earnings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BalancePage()),
                      );
                    },
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Account',
                    subtitle: 'Manage your TryHub account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountPage(),
                        ),
                      );
                    },
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.qr_code_2,
                    title: 'My QR Code',
                    subtitle: 'Share your TryHub profile',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 27),

              sectionTitle('Creator'),

              const SizedBox(height: 10),

              menuBox(
                children: [
                  menuItem(
                    context: context,
                    icon: Icons.video_settings_outlined,
                    title: 'Creator Tools',
                    subtitle: 'Manage your creator account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatorToolsPage(),
                        ),
                      );
                    },
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.live_tv_outlined,
                    title: 'LIVE Center',
                    subtitle: 'Manage LIVE activity',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LicensePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 27),

              sectionTitle('Content & Activity'),

              const SizedBox(height: 10),

              menuBox(
                children: [
                  menuItem(
                    context: context,
                    icon: Icons.history,
                    title: 'Activity Center',
                    subtitle: 'Watch history and activity',
                    onTap: () {},
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.bookmark_border,
                    title: 'Favorites',
                    subtitle: 'Saved videos and content',
                    onTap: () {},
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.download_outlined,
                    title: 'Downloads',
                    subtitle: 'Manage downloaded content',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 27),

              sectionTitle('Settings'),

              const SizedBox(height: 10),

              menuBox(
                children: [
                  menuItem(
                    context: context,
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    subtitle: 'Control your privacy',
                    onTap: () {},
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    subtitle: 'Manage notifications',
                    onTap: () {},
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {},
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.security_outlined,
                    title: 'Security',
                    subtitle: 'Password and login security',
                    onTap: () {},
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Settings & Privacy',
                    subtitle: 'More TryHub settings',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 27),

              sectionTitle('Support & About'),

              const SizedBox(height: 10),

              menuBox(
                children: [
                  menuItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help with TryHub',
                    onTap: () {},
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.feedback_outlined,
                    title: 'Report a Problem',
                    subtitle: 'Tell us about a problem',
                    onTap: () {},
                  ),

                  divider(),

                  menuItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'About TryHub',
                    subtitle: 'Terms, policies and version',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFE2C55)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Color(0xFFFE2C55),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'TryHub',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget menuBox({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  static Widget menuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 12, 12, 12),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 15),
          ],
        ),
      ),
    );
  }

  static Widget divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(height: 1, thickness: 0.5, color: Colors.grey.shade900),
    );
  }
}
