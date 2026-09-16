import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            accountItem(
              icon: Icons.person_outline_rounded,
              title: 'Account Information',
              subtitle: 'Phone number, email and account details',
              onTap: () {
                // Navigator.push(...)
              },
            ),

            accountItem(
              icon: Icons.lock_outline_rounded,
              title: 'Password',
              subtitle: 'Change your account password',
              onTap: () {
                // Open password page
              },
            ),

            accountItem(
              icon: Icons.key_rounded,
              title: 'Passkey',
              subtitle: 'Sign in securely without a password',
              onTap: () {
                // Open passkey page
              },
            ),

            accountItem(
              icon: Icons.verified_user_outlined,
              title: 'Verification',
              subtitle: 'Verify your identity or account',
              onTap: () {
                // Open verification page
              },
            ),

            accountItem(
              icon: Icons.business_center_outlined,
              title: 'Verified Business Account',
              subtitle: 'Business verification and account tools',
              onTap: () {
                // Open business verification page
              },
            ),

            accountItem(
              icon: Icons.storefront_outlined,
              title: 'TryHub Shop for Seller',
              subtitle: 'Manage your seller account and shop',
              onTap: () {
                // Open seller/shop page
              },
            ),

            const SizedBox(height: 12),

            sectionTitle('Your data'),

            accountItem(
              icon: Icons.download_rounded,
              title: 'Download Your Data',
              subtitle: 'Request a copy of your TryHub data',
              onTap: () {
                // Open download data page
              },
            ),

            const SizedBox(height: 12),

            sectionTitle('Account control'),

            accountItem(
              icon: Icons.pause_circle_outline_rounded,
              title: 'Deactivate Account',
              subtitle: 'Temporarily deactivate your account',
              onTap: () {
                // Open deactivate page
              },
            ),

            accountItem(
              icon: Icons.delete_outline_rounded,
              title: 'Delete Account',
              subtitle: 'Permanently delete your TryHub account',
              danger: true,
              onTap: () {
                showDeleteDialog(context);
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
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

  static Widget accountItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
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
            color: danger
                ? Colors.red.withOpacity(0.12)
                : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: danger ? const Color(0xFFFF4D5E) : Colors.white70,
            size: 22,
          ),
        ),

        title: Text(
          title,
          style: TextStyle(
            color: danger ? const Color(0xFFFF4D5E) : Colors.white,
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

  static void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B1B),

          title: const Text(
            'Delete account?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),

          content: const Text(
            'Deleting your account is permanent. Your profile and account data may no longer be available.',
            style: TextStyle(color: Colors.white70),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // Call backend delete-account API here.
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFFF4D5E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
