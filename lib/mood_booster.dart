import 'package:flutter/material.dart';
import 'home_screen.dart'; // adjust the path if needed
import 'mood_music.dart' as music; // import your playlist screen
import 'joy_gallery.dart' as photo;

class MoodBoosterScreen extends StatelessWidget {
  const MoodBoosterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: const Icon(Icons.home, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Mood Booster Card
              Container(
                width: double.infinity,
                height: 125,
                decoration: BoxDecoration(
                  color: const Color(0xFFB4D9FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/background_moodbooster.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Mood Booster",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Choose an activity to boost Her mood",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 10,
                      child: Image.asset('assets/robot2.png', height: 100),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Grid of Activities
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 3 / 2.5,
                  children: [
                    const _ActivityTile(
                      icon: Icons.self_improvement,
                      title: 'Meditation',
                      description: 'Simple breathing exercise for instant calm',
                      time: '10 mins',
                    ),
                    _ActivityTile(
                      icon: Icons.music_note,
                      title: 'Mood Music',
                      description: 'Curated playlists to match and lift your mood.',
                      time: '5 mins',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const music.CalmingPlaylistPage(),
                          ),
                        );
                      },
                    ),
                    _ActivityTile(
                      icon: Icons.photo,
                      title: 'Joy Gallery',
                      description: 'Your collection of happy moments',
                      time: '2 mins',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const photo.JoyGalleryPage(),
                          ),
                        );
                      },
                    ),

                    const _ActivityTile(
                      icon: Icons.chat,
                      title: 'Positive Chat',
                      description: 'Connect with supportive community',
                      time: '10 mins',
                    ),
                    const _ActivityTile(
                      icon: Icons.spa,
                      title: 'Deep Breathing',
                      description: 'Simple breathing exercise for instant calm',
                      time: '5 mins',
                    ),
                    const _ActivityTile(
                      icon: Icons.flash_on,
                      title: 'Quick Breathing',
                      description: 'Simple breathing exercise for instant calm',
                      time: '3 mins',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final VoidCallback? onTap;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFBDD1FD),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.deepPurple, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
            ),
            const Spacer(),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
