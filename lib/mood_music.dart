import 'package:flutter/material.dart';
import 'home_screen.dart' as home;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CalmingPlaylistPage(),
    );
  }
}

class CalmingPlaylistPage extends StatelessWidget {
  const CalmingPlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const home.HomeScreen()),
                      );
                    },
                    child: const Icon(Icons.home_outlined),
                  ),
                  const Text(
                    'Calming Playlist',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Icon(Icons.menu),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Album Art
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/the_hills.jpeg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Song Info
            Column(
              children: [
                const Text(
                  'The hills',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Weeknd',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Calm'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Waveform Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('Waveform Placeholder')),
              ),
            ),

            const SizedBox(height: 20),

            // Recommended List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Recommended', style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(Icons.search),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: [
                  buildSongTile('starboy', 'weeknd', 'assets/song.jpeg'),
                  buildSongTile('reminder', 'weeknd', 'assets/song.jpeg'),
                  buildSongTile('party monster', 'weeknd', 'assets/song.jpeg'),
                  buildSongTile('gasoline', 'weeknd', 'assets/song.jpeg'),
                ],
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('assets/the_hills.jpeg', height: 40, width: 40),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('The hills'),
                          Text('Weeknd', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.skip_previous),
                      SizedBox(width: 8),
                      Icon(Icons.play_circle_fill, size: 40),
                      SizedBox(width: 8),
                      Icon(Icons.skip_next),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSongTile(String title, String artist, String imagePath) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
      ),
      title: Text(title),
      subtitle: Text(artist),
      trailing: const Icon(Icons.more_vert),
    );
  }
}

// ======================
// HOME SCREEN CLASS
// ======================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text('Welcome to the Home Screen!'),
      ),
    );
  }
}
