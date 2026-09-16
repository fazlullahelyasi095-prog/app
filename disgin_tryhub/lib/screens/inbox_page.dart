import 'package:flutter/material.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final TextEditingController _searchController = TextEditingController();

  bool searching = false;

  final List<Map<String, dynamic>> messages = [
    {
      'name': 'Ahmad',
      'username': '@ahmad',
      'message': 'Hello! How are you?',
      'time': '10:24 AM',
      'unread': 3,
      'online': true,
    },
    {
      'name': 'Sara',
      'username': '@sara',
      'message': 'Sent you a video',
      'time': '9:45 AM',
      'unread': 1,
      'online': true,
    },
    {
      'name': 'David',
      'username': '@david',
      'message': 'Thanks ❤️',
      'time': 'Yesterday',
      'unread': 0,
      'online': false,
    },
    {
      'name': 'Mina',
      'username': '@mina',
      'message': 'Let’s go LIVE 🔥',
      'time': 'Yesterday',
      'unread': 0,
      'online': true,
    },
    {
      'name': 'Alex',
      'username': '@alex',
      'message': 'You: See you tomorrow',
      'time': 'Monday',
      'unread': 0,
      'online': false,
    },
    {
      'name': 'TryHub Creator',
      'username': '@tryhub',
      'message': 'Welcome to TryHub!',
      'time': 'Sunday',
      'unread': 0,
      'online': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = messages.where((user) {
      final query = _searchController.text.toLowerCase();

      return user['name'].toString().toLowerCase().contains(query) ||
          user['username'].toString().toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searching = !searching;

                if (!searching) {
                  _searchController.clear();
                }
              });
            },
            icon: Icon(
              searching ? Icons.close : Icons.search,
              color: Colors.black,
              size: 27,
            ),
          ),

          IconButton(
            onPressed: () {
              _showNewMessage(context);
            },
            icon: const Icon(Icons.edit_square, color: Colors.black, size: 24),
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: Column(
        children: [
          // =====================================================
          // SEARCH
          // =====================================================

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),

            child: searching
                ? Padding(
                    key: const ValueKey('search'),

                    padding: const EdgeInsets.fromLTRB(14, 5, 14, 12),

                    child: Container(
                      height: 44,

                      decoration: BoxDecoration(
                        color: const Color(0xfff1f1f2),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      child: TextField(
                        controller: _searchController,
                        autofocus: true,

                        onChanged: (_) {
                          setState(() {});
                        },

                        decoration: const InputDecoration(
                          hintText: 'Search',

                          prefixIcon: Icon(Icons.search, color: Colors.black54),

                          border: InputBorder.none,

                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // =====================================================
          // ACTIVITY
          // =====================================================
          if (!searching)
            InkWell(
              onTap: () {
                _openActivity();
              },

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                child: Row(
                  children: [
                    // Activity icon

                    Stack(
                      clipBehavior: Clip.none,

                      children: [
                        Container(
                          width: 52,
                          height: 52,

                          decoration: const BoxDecoration(
                            color: Color(0xfffe2c55),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),

                        Positioned(
                          right: -2,
                          top: -2,

                          child: Container(
                            width: 18,
                            height: 18,

                            alignment: Alignment.center,

                            decoration: const BoxDecoration(
                              color: Color(0xfffe2c55),
                              shape: BoxShape.circle,
                            ),

                            child: const Text(
                              '5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Activities',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Likes, comments, mentions and followers',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            ),

          if (!searching) const Divider(height: 1, thickness: 0.5, indent: 80),

          // =====================================================
          // NEW FOLLOWERS
          // =====================================================
          if (!searching)
            InkWell(
              onTap: () {},

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,

                      decoration: const BoxDecoration(
                        color: Color(0xff25f4ee),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'New followers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'See your new followers',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            ),

          // =====================================================
          // MESSAGES TITLE
          // =====================================================
          if (!searching)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 8),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // =====================================================
          // MESSAGE LIST
          // =====================================================
          Expanded(
            child: filteredMessages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 55,
                          color: Colors.black26,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No messages found',
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredMessages.length,

                    itemBuilder: (context, index) {
                      final user = filteredMessages[index];

                      return _messageItem(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // MESSAGE ITEM
  // ===========================================================

  Widget _messageItem(Map<String, dynamic> user) {
    final int unread = user['unread'] ?? 0;
    final bool online = user['online'] ?? false;

    return InkWell(
      onTap: () {
        _openChat(user);
      },

      onLongPress: () {
        _messageOptions(user);
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        child: Row(
          children: [
            // =================================================
            // PROFILE
            // =================================================

            Stack(
              clipBehavior: Clip.none,

              children: [
                Container(
                  width: 56,
                  height: 56,

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffeeeeee),
                  ),

                  child: const Icon(
                    Icons.person,
                    color: Colors.black45,
                    size: 31,
                  ),
                ),

                // ONLINE DOT
                if (online)
                  Positioned(
                    right: 1,
                    bottom: 1,

                    child: Container(
                      width: 15,
                      height: 15,

                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,

                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 13),

            // =================================================
            // NAME + MESSAGE
            // =================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    user['name'],

                    maxLines: 1,

                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,

                      fontWeight: unread > 0
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    user['message'],

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: unread > 0 ? Colors.black87 : Colors.black54,

                      fontSize: 13,

                      fontWeight: unread > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // =================================================
            // TIME + UNREAD
            // =================================================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Text(
                  user['time'],

                  style: const TextStyle(color: Colors.black45, fontSize: 11),
                ),

                const SizedBox(height: 7),

                if (unread > 0)
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),

                    padding: const EdgeInsets.symmetric(horizontal: 5),

                    alignment: Alignment.center,

                    decoration: const BoxDecoration(
                      color: Color(0xfffe2c55),
                      shape: BoxShape.circle,
                    ),

                    child: Text(
                      unread > 99 ? '99+' : '$unread',

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // OPEN CHAT
  // ===========================================================

  void _openChat(Map<String, dynamic> user) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            ChatPage(name: user['name'], username: user['username']),
      ),
    );
  }

  // ===========================================================
  // ACTIVITY
  // ===========================================================

  void _openActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActivityPage()),
    );
  }

  // ===========================================================
  // NEW MESSAGE
  // ===========================================================

  void _showNewMessage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,

          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 40,
                height: 4,

                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(16),

                child: Text(
                  'New message',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),

                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search people',

                    prefixIcon: const Icon(Icons.search),

                    filled: true,
                    fillColor: const Color(0xfff1f1f2),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final user = messages[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffeeeeee),

                        child: Icon(Icons.person, color: Colors.black54),
                      ),

                      title: Text(
                        user['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      subtitle: Text(user['username']),

                      onTap: () {
                        Navigator.pop(context);
                        _openChat(user);
                      },
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

  // ===========================================================
  // MESSAGE OPTIONS
  // ===========================================================

  void _messageOptions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,

      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin_outlined),
                title: const Text('Pin conversation'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.volume_off_outlined),
                title: const Text('Mute notifications'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text(
                  'Delete conversation',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===============================================================
// CHAT PAGE
// ===============================================================

class ChatPage extends StatefulWidget {
  final String name;
  final String username;

  const ChatPage({super.key, required this.name, required this.username});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  final List<String> chatMessages = ['Hello 👋', 'Welcome to TryHub!'];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      chatMessages.add(text);
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.black),

        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xffeeeeee),

              child: Icon(Icons.person, color: Colors.black54),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  widget.name,

                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  widget.username,

                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.phone_outlined)),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),

              itemCount: chatMessages.length,

              itemBuilder: (context, index) {
                return Align(
                  alignment: index < 2
                      ? Alignment.centerLeft
                      : Alignment.centerRight,

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),

                    decoration: BoxDecoration(
                      color: index < 2
                          ? const Color(0xffeeeeee)
                          : const Color(0xfffe2c55),

                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Text(
                      chatMessages[index],

                      style: TextStyle(
                        color: index < 2 ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // MESSAGE INPUT
          SafeArea(
            top: false,

            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),

              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xfff1f1f2),
                        borderRadius: BorderRadius.circular(25),
                      ),

                      child: TextField(
                        controller: messageController,

                        textInputAction: TextInputAction.send,

                        onSubmitted: (_) {
                          sendMessage();
                        },

                        decoration: const InputDecoration(
                          hintText: 'Send a message...',

                          border: InputBorder.none,

                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: sendMessage,

                    icon: const Icon(
                      Icons.send_rounded,
                      color: Color(0xfffe2c55),
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
}

// ===============================================================
// ACTIVITY PAGE
// ===============================================================

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.black),

        title: const Text(
          'Activities',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        children: const [
          ActivityItem(
            icon: Icons.favorite,
            title: 'Ahmad liked your video',
            time: '2m',
          ),

          ActivityItem(
            icon: Icons.person_add,
            title: 'Sara started following you',
            time: '10m',
          ),

          ActivityItem(
            icon: Icons.chat_bubble,
            title: 'David commented on your video',
            time: '1h',
          ),

          ActivityItem(
            icon: Icons.alternate_email,
            title: 'Mina mentioned you',
            time: '3h',
          ),

          ActivityItem(
            icon: Icons.card_giftcard,
            title: 'Alex sent you a gift',
            time: '5h',
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xfff1f1f2),

        child: Icon(icon, color: const Color(0xfffe2c55)),
      ),

      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),

      trailing: Text(
        time,
        style: const TextStyle(color: Colors.black45, fontSize: 12),
      ),
    );
  }
}
