import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool voiceAlertsEnabled = true;
  bool emergencyContactsEnabled = true;
  double fontSize = 16.0;
  String selectedTheme = 'Default';

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
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile section
          SettingsSection(
            title: 'Profile',
            children: [
              SettingsTile(
                icon: Icons.person,
                title: 'Personal Information',
                subtitle: 'Update your profile details',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.medical_information,
                title: 'Medical Information',
                subtitle: 'Manage your health data',
                onTap: () {},
              ),
            ],
          ),

          // Notifications section
          SettingsSection(
            title: 'Notifications',
            children: [
              SettingsSwitchTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive alerts and reminders',
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              SettingsSwitchTile(
                icon: Icons.volume_up,
                title: 'Voice Alerts',
                subtitle: 'Spoken notifications',
                value: voiceAlertsEnabled,
                onChanged: (value) {
                  setState(() {
                    voiceAlertsEnabled = value;
                  });
                },
              ),
            ],
          ),

          // Accessibility section
          SettingsSection(
            title: 'Accessibility',
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields, color: const Color(0xFF5EA8FF), size: 30),
                        const SizedBox(width: 15),
                        const Text(
                          'Font Size',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Slider(
                      value: fontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 6,
                      activeColor: const Color(0xFF5EA8FF),
                      label: '${fontSize.round()}px',
                      onChanged: (value) {
                        setState(() {
                          fontSize = value;
                        });
                      },
                    ),
                    Text(
                      'Sample text at ${fontSize.round()}px',
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Emergency section
          SettingsSection(
            title: 'Emergency',
            children: [
              SettingsTile(
                icon: Icons.contact_emergency,
                title: 'Emergency Contacts',
                subtitle: 'Manage your emergency contacts',
                onTap: () {},
              ),
              SettingsSwitchTile(
                icon: Icons.location_on,
                title: 'Location Sharing',
                subtitle: 'Share location during emergencies',
                value: emergencyContactsEnabled,
                onChanged: (value) {
                  setState(() {
                    emergencyContactsEnabled = value;
                  });
                },
              ),
            ],
          ),

          // Device section
          SettingsSection(
            title: 'Device',
            children: [
              SettingsTile(
                icon: Icons.wifi,
                title: 'Wi-Fi Settings',
                subtitle: 'Manage network connections',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.bluetooth,
                title: 'Bluetooth',
                subtitle: 'Connect to devices',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.storage,
                title: 'Storage',
                subtitle: 'Manage device storage',
                onTap: () {},
              ),
            ],
          ),

          // Support section
          SettingsSection(
            title: 'Support',
            children: [
              SettingsTile(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help with using the app',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 15),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5EA8FF),
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 30),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(icon, color: const Color(0xFF5EA8FF), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(icon, color: const Color(0xFF5EA8FF), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: Switch(
          value: value,
          activeColor: const Color(0xFF5EA8FF),
          onChanged: onChanged,
        ),
      ),
    );
  }
}