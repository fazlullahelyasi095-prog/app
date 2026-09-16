import 'package:flutter/material.dart';

class FollowersScreen extends StatefulWidget {
  final String title;

  const FollowersScreen({super.key, required this.title});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final List<Map<String, dynamic>> users = List.generate(
    20,
    (index) => {
      'name': 'TryHub User ${index + 1}',
      'username': '@user${index + 1}',
      'following': false,
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title),
        centerTitle: true,
      ),

      body: ListView.separated(
        itemCount: users.length,

        separatorBuilder: (_, _) =>
            Divider(color: Colors.grey.shade900, height: 1),

        itemBuilder: (context, index) {
          final user = users[index];

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),

            title: Text(
              user['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Text(
              user['username'],
              style: const TextStyle(color: Colors.grey),
            ),

            trailing: SizedBox(
              width: 105,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: user['following']
                      ? Colors.grey.shade800
                      : Colors.pink,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {
                  setState(() {
                    user['following'] = !user['following'];
                  });
                },

                child: Text(
                  user['following'] ? 'Following' : 'Follow',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
