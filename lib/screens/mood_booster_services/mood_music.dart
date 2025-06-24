import 'package:flutter/material.dart';
import '../../models/selected_song_model.dart';
import '../../widgets/music_preview_card.dart';
import 'dart:math' as Math;
class MoodMusicPage extends StatefulWidget {
  final SelectedSong? selectedSong;
  const MoodMusicPage({Key? key, this.selectedSong}) : super(key: key);
  @override
  _MoodMusicPageState createState() => _MoodMusicPageState();
}

class _MoodMusicPageState extends State<MoodMusicPage> {
  bool isPlaying = false;
  double currentPosition = 0.35; // 35% progress as shown in the design
  bool _showMusicCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F4FD), // Light blue at top
                  Color(0xFFF0E6FF), // Light purple
                  Color(0xFFFFE6F0), // Light pink at bottom
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 100), // Space for bottom player
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back, color: Colors.blue, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Go Back',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Title
                      Text(
                        'Calming Playlist',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 30),

                      // Album Art
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF98E4D6),
                                  Color(0xFFCDB4DB),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'PINI',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      Text(
                                        'BINDU',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'YUKI NAVARATHNE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Song Title and Artist
                      Text(
                        'Pini Bindu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Yuki Navarathne',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Progress Bar
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('0:35', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Spacer(),
                              ],
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: 60,
                              child: CustomPaint(
                                painter: WaveformPainter(progress: currentPosition),
                                size: Size(double.infinity, 60),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // Recommended Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recommended',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Icon(Icons.search, color: Colors.grey[600]),
                              ],
                            ),
                            SizedBox(height: 20),
                            _buildSongItem('Yashodara', 'Gangadara', '3:30', 'assets/song1.jpg'),
                            _buildSongItem('Dura Akahe', 'Charitha', '3:30', 'assets/song2.jpg'),
                            _buildSongItem('Viramaye', 'Ridma', '3:30', 'assets/song3.jpg'),
                            SizedBox(height: 20), // Extra space at bottom
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.selectedSong != null && _showMusicCard)
            Positioned.fill(
              child: MusicPreviewCard(
                song: widget.selectedSong!,
                onClose: () {
                  setState(() {
                    _showMusicCard = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSongItem(String title, String artist, String duration, String imagePath) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: Icon(Icons.music_note, color: Colors.grey[600]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  artist,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.more_horiz, color: Colors.grey[600]),
          SizedBox(width: 10),
          Icon(Icons.menu, color: Colors.grey[600]),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;

  WaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final playedPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final unplayedPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barCount = 60;
    final barWidth = size.width / barCount;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final normalizedIndex = i / barCount;

      // Create varied heights for waveform effect
      final height = (centerY * 0.8) *
          (0.3 + 0.7 * (0.5 + 0.5 * Math.sin(normalizedIndex * 10))) *
          (0.8 + 0.4 * Math.sin(normalizedIndex * 25));

      final isPlayed = normalizedIndex <= progress;

      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        isPlayed ? playedPaint : unplayedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Add this import at the top
