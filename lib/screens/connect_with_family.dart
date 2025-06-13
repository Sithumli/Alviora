import 'package:flutter/material.dart';

import 'call_screen.dart';

class ConnectWithFamilyScreen extends StatelessWidget {
  const ConnectWithFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,  // increase height here
        title: SizedBox(
          height: 80, // enough for 2 lines with big fonts
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: 'Connect ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                    ),
                  ),
                  TextSpan(
                    text: 'with \nFamily Members',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _FamilyMemberCard(
                    name: 'Mr. Avishka',
                    lastActive: '2 minutes ago',
                    onTrackPressed: () => _handleTrackPressed(context, 'Mr. Avishka'),
                  ),
                  const SizedBox(height: 16),
                  _FamilyMemberCard(
                    name: 'Mr.Shenal',
                    lastActive: '4 minutes ago',
                    onTrackPressed: () => _handleTrackPressed(context, 'Mr.Shenal'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'Back',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTrackPressed(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tracking $name...')),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final String name;
  final String lastActive;
  final VoidCallback onTrackPressed;

  const _FamilyMemberCard({
    required this.name,
    required this.lastActive,
    required this.onTrackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last activity: $lastActive',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              color: Colors.blue,
              thickness: 1.5,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.video_call, color: Colors.blue, size: 50),
                      tooltip: 'Video Call',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CallScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.blue, size: 50),
                      tooltip: 'Call',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Starting call with $name...')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.message_rounded, color: Colors.blue, size: 50),
                      tooltip: 'Message',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Message with $name...')),
                        );
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onTrackPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.location_on, size: 20),  // Location icon
                      SizedBox(width: 6),                  // Spacing between icon and text
                      Text(
                        'Track',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
