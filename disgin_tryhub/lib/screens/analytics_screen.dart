import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 228, 227, 227),
        elevation: 0,
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
          'TryHub Studio',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.settings_applications,
              color: Colors.black,
              size: 40,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // OVERVIEW
              // =========================

              const Text(
                'Analytics ',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Your account performance',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.video_library_outlined,
                      title: 'Posts',
                      value: '24',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      icon: Icons.visibility_outlined,
                      title: 'Views',
                      value: '125.4K',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.people_outline,
                      title: 'Followers',
                      value: '18.2K',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      icon: Icons.favorite_border,
                      title: 'Likes',
                      value: '92.8K',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // =========================
              // MONETIZATION
              // =========================
              const Text(
                'Monetization',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Your earnings and creator income',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 18),

              _monetizationCard(
                icon: Icons.play_circle_outline,
                title: 'Video Earnings',
                subtitle: 'Earnings from eligible videos',
                value: '\$0.00',
              ),

              const SizedBox(height: 12),

              _monetizationCard(
                icon: Icons.card_giftcard_outlined,
                title: 'Video Gifts',
                subtitle: 'Gifts received on videos',
                value: '\$0.00',
              ),

              const SizedBox(height: 12),

              _monetizationCard(
                icon: Icons.live_tv_outlined,
                title: 'LIVE Gifts',
                subtitle: 'Gifts received during LIVE',
                value: '\$0.00',
              ),

              const SizedBox(height: 12),

              _monetizationCard(
                icon: Icons.workspaces,
                title: 'Subscriptions',
                subtitle: 'Income from subscribers',
                value: '\$0.00',
              ),

              const SizedBox(height: 30),

              // =========================
              // PERFORMANCE
              // =========================
              const Text(
                'Performance',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _performanceRow(title: 'Average video views', value: '5.2K'),

              _performanceRow(title: 'Profile views', value: '8.7K'),

              _performanceRow(title: 'New followers', value: '+1.2K'),

              _performanceRow(title: 'Total watch time', value: '320h'),

              const SizedBox(height: 30),

              // =========================
              // TOP CONTENT
              // =========================
              const Text(
                'Top Content',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.video_collection_outlined,
                      size: 34,
                      color: Colors.black87,
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Best performing video',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            '48.3K views',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xffF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: const Color(0xffFE2C55)),

          const SizedBox(height: 18),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  static Widget _monetizationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffF7F7F7),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.black, size: 25),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),

          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          const SizedBox(width: 6),

          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
        ],
      ),
    );
  }

  static Widget _performanceRow({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),

          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
