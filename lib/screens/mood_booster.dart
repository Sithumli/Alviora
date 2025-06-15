import 'package:flutter/material.dart';
import 'mood_booster_services/meditation.dart';

class MoodBoosterScreen extends StatelessWidget {
  const MoodBoosterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Go Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF4A90E2),
                    size: 20,
                  ),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Header Card with Bot
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF6BA3F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mood Booster',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Choose an activity to boost your mood',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Decorative dots
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bot illustration
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Bot body
                          Container(
                            width: 50,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          // Bot head
                          Positioned(
                            top: 15,
                            child: Container(
                              width: 30,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  '😊',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                          // Antenna
                          Positioned(
                            top: 8,
                            child: Container(
                              width: 2,
                              height: 8,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A90E2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Activity Grid - 2 rows, 3 columns
              Expanded(
                child: Column(
                  children: [
                    // First Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildActivityCard(
                            context,
                            icon: Icons.self_improvement,
                            title: 'Meditation',
                            subtitle: 'Mindful meditation exercises for mental calm',
                            duration: '10 mins',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MeditationApp()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActivityCard(
                            context,
                            icon: Icons.music_note,
                            title: 'Mood Music',
                            subtitle: 'Curated playlists to enhance and lift your mood',
                            duration: '5 mins',
                            onTap: () {
                              // Navigate to MoodMusicPage()
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActivityCard(
                            context,
                            icon: Icons.chat_bubble_outline,
                            title: 'Positive Chat',
                            subtitle: 'Connect with supportive community',
                            duration: '15 mins',
                            onTap: () {
                              // Navigate to PositiveChatPage()
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Second Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildActivityCard(
                            context,
                            icon: Icons.photo_library_outlined,
                            title: 'Joy Gallery',
                            subtitle: 'Your collection of happy moments',
                            duration: '3 mins',
                            onTap: () {

                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActivityCard(
                            context,
                            icon: Icons.air,
                            title: 'Deep Breathing',
                            subtitle: 'Simple breathing exercises for balance',
                            duration: '5 mins',
                            onTap: () {
                              // Navigate to DeepBreathingPage()
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActivityCard(
                            context,
                            icon: Icons.speed,
                            title: 'Quick Breathing',
                            subtitle: 'Rapid breathing exercises for instant calm',
                            duration: '2 mins',
                            onTap: () {
                              // Navigate to QuickBreathingPage()
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String duration,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF6BA3F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23, // Increased from 15 to 18
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14, // Increased from 12 to 14
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Duration
            Text(
              duration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14, // Increased from 12 to 14
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}