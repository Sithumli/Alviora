import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SettingsScreen(),
  ));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.blue),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.blue,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage('assets/avatar.png'), // replace with your image
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 16, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Adam Smith",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "adam@mail.com",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const SettingsItem(icon: Icons.person, title: 'Account'),
            const SettingsItem(icon: Icons.notifications, title: 'Notification'),
            const SettingsItem(icon: Icons.remove_red_eye, title: 'Appearance'),
            const SettingsItem(icon: Icons.lock, title: 'Privacy & Security'),
            const SettingsItem(icon: Icons.volume_up, title: 'Sound'),
            const SettingsItem(icon: Icons.language, title: 'Language'),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF688BFF), Color(0xFFA7B9FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const SettingsItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      onTap: () {},
    );
  }
}
