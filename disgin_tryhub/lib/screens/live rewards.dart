import 'package:flutter/material.dart';

class LiveRewardsPage extends StatelessWidget {
  const LiveRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'LIVE Rewards',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: Colors.black),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Balance Card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  const Text(
                    'Estimated rewards',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '\$245.80',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Updated recently',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryItem(title: 'Today', value: '\$18.40'),
                      ),
                      Container(
                        height: 45,
                        width: 1,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(
                        child: _summaryItem(
                          title: 'This month',
                          value: '\$126.20',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Withdraw',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Live Gifts
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  _menuItem(
                    icon: Icons.monetization_on_outlined,
                    iconColor: const Color.fromARGB(255, 255, 153, 1),
                    title: 'Coins',
                    titleColor: Colors.black,
                    subtitle: 'View your coin balance and top up',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Analytics
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      'LIVE performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _analyticsCard(
                            icon: Icons.visibility_outlined,
                            value: '24.8K',
                            title: 'Viewers',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _analyticsCard(
                            icon: Icons.favorite_border,
                            value: '36.4K',
                            title: 'Likes',
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _analyticsCard(
                            icon: Icons.card_giftcard,
                            value: '1,240',
                            title: 'Gifts',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _analyticsCard(
                            icon: Icons.person_add_alt_1,
                            value: '425',
                            title: 'New followers',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// History
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _menuItem(
                    icon: Icons.history,
                    iconColor: Colors.black,
                    title: 'Reward history',
                    subtitle: 'View all LIVE reward transactions',
                    onTap: () {},
                  ),

                  _divider(),

                  _menuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: Colors.green,
                    title: 'Withdrawal history',
                    subtitle: 'Check your previous withdrawals',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                'LIVE rewards are calculated from eligible gifts and other creator reward programs.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _summaryItem({required String title, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  static Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 23),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 15,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  static Widget _analyticsCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  static Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 78),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
