import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5EA8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment, color: Colors.white, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black12)],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: TextStyle(fontSize: 18),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Color(0xFF5EA8FF), size: 30),
              ),
              style: TextStyle(fontSize: 18),
            ),
          ),

          // Messages list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                MessageTile(
                  name: 'Dr. Sarah Johnson',
                  message: 'Your appointment is confirmed for tomorrow at 2 PM',
                  time: '10:30 AM',
                  isUnread: true,
                  avatar: Icons.medical_services,
                ),
                MessageTile(
                  name: 'Family Care Team',
                  message: 'Daily medication reminder - Evening dose',
                  time: '9:15 AM',
                  isUnread: true,
                  avatar: Icons.family_restroom,
                ),
                MessageTile(
                  name: 'John (Son)',
                  message: 'Hi mom! How are you feeling today?',
                  time: 'Yesterday',
                  isUnread: false,
                  avatar: Icons.person,
                ),
                MessageTile(
                  name: 'Nurse Mary',
                  message: 'Your blood pressure reading looks good today',
                  time: 'Yesterday',
                  isUnread: false,
                  avatar: Icons.local_hospital,
                ),
                MessageTile(
                  name: 'Emma (Daughter)',
                  message: 'Can\'t wait to see you this weekend!',
                  time: '2 days ago',
                  isUnread: false,
                  avatar: Icons.person,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5EA8FF),
        onPressed: () {},
        child: const Icon(Icons.message, color: Colors.white, size: 30),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isUnread;
  final IconData avatar;

  const MessageTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.isUnread,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
        border: isUnread ? Border.all(color: const Color(0xFF5EA8FF), width: 2) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF5EA8FF),
            child: Icon(avatar, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnread ? const Color(0xFF5EA8FF) : Colors.grey,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: isUnread ? Colors.black87 : Colors.grey[600],
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF5EA8FF),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}