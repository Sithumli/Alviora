import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool emailNotifications = true;
  bool pushNotifications = true;
  bool smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Email Notifications', style: TextStyle(fontSize: 16)),
              value: emailNotifications,
              onChanged: (val) {
                setState(() {
                  emailNotifications = val;
                });
              },
              activeColor: const Color(0xFF688BFF),
            ),
            SwitchListTile(
              title: const Text('Push Notifications', style: TextStyle(fontSize: 16)),
              value: pushNotifications,
              onChanged: (val) {
                setState(() {
                  pushNotifications = val;
                });
              },
              activeColor: const Color(0xFF688BFF),
            ),
            SwitchListTile(
              title: const Text('SMS Notifications', style: TextStyle(fontSize: 16)),
              value: smsNotifications,
              onChanged: (val) {
                setState(() {
                  smsNotifications = val;
                });
              },
              activeColor: const Color(0xFF688BFF),
            ),
          ],
        ),
      ),
    );
  }
}
