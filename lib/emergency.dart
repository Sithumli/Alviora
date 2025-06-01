import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  final List<Map<String, String>> hotlines = const [
    {
      'service': 'Police Emergency',
      'number': '119',
    },
    {
      'service': 'Ambulance / Fire & Rescue',
      'number': '110',
    },
    {
      'service': 'Disaster Management Centre',
      'number': '117',
    },
    {
      'service': 'Women Help Line',
      'number': '1938',
    },
    {
      'service': 'Child Help Line',
      'number': '1929',
    },
    {
      'service': 'Mental Health Support (CCCline)',
      'number': '1333',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: hotlines.length,
        itemBuilder: (context, index) {
          final hotline = hotlines[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text(
                hotline['service']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Hotline: ${hotline['number']}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.phone_forwarded_rounded, color: Colors.blueAccent),
                onPressed: () async {
                  final Uri phoneUri = Uri(scheme: 'tel', path: hotline['number']);
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot launch dialer')),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
