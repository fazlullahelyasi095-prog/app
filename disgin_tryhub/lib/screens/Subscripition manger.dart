import 'package:flutter/material.dart';

class SubscriptionManagerPage extends StatefulWidget {
  const SubscriptionManagerPage({super.key});

  @override
  State<SubscriptionManagerPage> createState() =>
      _SubscriptionManagerPageState();
}

class _SubscriptionManagerPageState extends State<SubscriptionManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
        ),

        title: const Text(
          'Subscription Manager',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorWeight: 2.5,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Expired'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [ActiveSubscriptionsTab(), ExpiredSubscriptionsTab()],
      ),
    );
  }
}

/// ACTIVE TAB
class ActiveSubscriptionsTab extends StatelessWidget {
  const ActiveSubscriptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SubscriptionCard(
          avatar:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
          username: 'Sarah',
          plan: 'Monthly subscription',
          price: '\$4.99',
          dateTitle: 'Renews on',
          date: 'Sep 28, 2026',
          active: true,
        ),

        SizedBox(height: 12),

        SubscriptionCard(
          avatar:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
          username: 'David',
          plan: 'Monthly subscription',
          price: '\$9.99',
          dateTitle: 'Renews on',
          date: 'Oct 03, 2026',
          active: true,
        ),
      ],
    );
  }
}

/// EXPIRED TAB
class ExpiredSubscriptionsTab extends StatelessWidget {
  const ExpiredSubscriptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SubscriptionCard(
          avatar:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
          username: 'Emily',
          plan: 'Monthly subscription',
          price: '\$4.99',
          dateTitle: 'Expired on',
          date: 'Aug 10, 2026',
          active: false,
        ),

        SizedBox(height: 12),

        SubscriptionCard(
          avatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
          username: 'Alex',
          plan: 'Monthly subscription',
          price: '\$7.99',
          dateTitle: 'Expired on',
          date: 'Jul 25, 2026',
          active: false,
        ),
      ],
    );
  }
}

/// SUBSCRIPTION CARD
class SubscriptionCard extends StatelessWidget {
  final String avatar;
  final String username;
  final String plan;
  final String price;
  final String dateTitle;
  final String date;
  final bool active;

  const SubscriptionCard({
    super.key,
    required this.avatar,
    required this.username,
    required this.plan,
    required this.price,
    required this.dateTitle,
    required this.date,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PROFILE PHOTO
          CircleAvatar(radius: 27, backgroundImage: NetworkImage(avatar)),

          const SizedBox(width: 12),

          /// INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.green.withOpacity(.10)
                            : Colors.grey.withOpacity(.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        active ? 'Active' : 'Expired',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.green : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  plan,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      '/ month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      '$dateTitle: ',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),

                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: Text(
                      active ? 'Manage' : 'View',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
