import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:just_audio/just_audio.dart'; // Add this dependency in pubspec.yaml

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalmingPlaylistPage(),
    );
  }
}

class CalmingPlaylistPage extends StatefulWidget {
  const CalmingPlaylistPage({super.key});

  @override
  State<CalmingPlaylistPage> createState() => _CalmingPlaylistPageState();
}

class _CalmingPlaylistPageState extends State<CalmingPlaylistPage> {
  List<Map<String, String>> _songs = [];

  String _selectedTitle = 'The Hills';
  String _selectedArtist = 'Weeknd';
  String _selectedImage =
      'https://cdn-images.dzcdn.net/images/cover/eea9f7fc913300e40307a0ff70dc73cf/250x250-000000-80-0-0.jpg';
  String _selectedAudioUrl = '';

  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://alviora-10650-default-rtdb.firebaseio.com/',
  );
  late final DatabaseReference _dbRef;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _dbRef = database.ref('selected_song');
    _audioPlayer = AudioPlayer();

    // Listen to changes in Firebase to get selected song and play
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          _selectedTitle = data['title'] ?? '';
          _selectedArtist = data['artist'] ?? '';
          _selectedImage = data['image'] ?? '';
          _selectedAudioUrl = data['audio_url'] ?? '';
        });

        if (_selectedAudioUrl.isNotEmpty) {
          _playAudio(_selectedAudioUrl);
        }
      }
    });
  }

  Future<void> searchSongs(String query) async {
    final url = Uri.parse('https://api.deezer.com/search?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List tracks = data['data'];

      final results = tracks.map<Map<String, String>>((track) {
        return {
          'title': track['title'] ?? '',
          'artist': track['artist']['name'] ?? '',
          'image': track['album']['cover_medium'] ?? '',
          'audio_url': track['preview'] ?? '', // Deezer preview URL for audio
        };
      }).toList();

      setState(() {
        _songs = results;
      });
    } else {
      print('Error fetching songs');
    }
  }

  void _openSearchDialog() {
    String query = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Songs'),
        content: TextField(
          onChanged: (value) => query = value,
          decoration: const InputDecoration(hintText: 'Type song name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (query.isNotEmpty) searchSongs(query);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _selectSong(Map<String, String> song) async {
    setState(() {
      _selectedTitle = song['title']!;
      _selectedArtist = song['artist']!;
      _selectedImage = song['image']!;
      _selectedAudioUrl = song['audio_url']!;
    });

    try {
      await _dbRef.set({
        'title': _selectedTitle,
        'artist': _selectedArtist,
        'image': _selectedImage,
        'audio_url': _selectedAudioUrl,
        'timestamp': ServerValue.timestamp,
      });
      print('Song info sent to Firebase');
    } catch (e) {
      print('Error sending song info to Firebase: $e');
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
      print('Playing audio from $url');
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Calming Playlist',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: _openSearchDialog,
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Selected Album Art
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _selectedImage.isNotEmpty
                    ? Image.network(
                  _selectedImage,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.music_note, size: 200),
                )
                    : const Icon(Icons.music_note, size: 200),
              ),
            ),

            const SizedBox(height: 10),

            Column(
              children: [
                Text(
                  _selectedTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedArtist,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recommended',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 24),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: _songs.isEmpty
                    ? [
                  buildSongTile('starboy', 'weeknd',
                      'https://cdns-images.dzcdn.net/images/cover/43ec7bb80e6a7d27d1e9a332b72af34f/250x250-000000-80-0-0.jpg',
                      onTap: () {
                        _selectSong({
                          'title': 'starboy',
                          'artist': 'weeknd',
                          'image':
                          'https://cdns-images.dzcdn.net/images/cover/43ec7bb80e6a7d27d1e9a332b72af34f/250x250-000000-80-0-0.jpg',
                          'audio_url': '', // no audio url here
                        });
                      }),
                ]
                    : _songs.map((song) {
                  return buildSongTile(
                      song['title']!,
                      song['artist']!,
                      song['image']!, onTap: () {
                    _selectSong(song);
                  });
                }).toList(),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
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
                        child: _selectedImage.isNotEmpty
                            ? Image.network(
                          _selectedImage,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.music_note),
                        )
                            : const Icon(Icons.music_note, size: 40),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedTitle),
                          Text(_selectedArtist,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
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

  static Widget buildSongTile(String title, String artist, String imagePath,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
        ),
      ),
      title: Text(title),
      subtitle: Text(artist),
      trailing: const Icon(Icons.more_vert),
    );
  }
}
