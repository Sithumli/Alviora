import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:just_audio/just_audio.dart';
import '../models/selected_song_model.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  StreamController<SelectedSong?> _songController = StreamController<SelectedSong?>.broadcast();
  Stream<SelectedSong?> get songStream => _songController.stream;
  
  DatabaseReference? _songListener;
  bool _isListening = false;
  int? _lastTimestamp;
  bool _isFirstEvent = true;

  // Start listening to Firebase for selected song updates
  void startListening() {
    if (_isListening) return;
    
    _isListening = true;
    _songListener = _database.child('selected_song');
    
    _songListener!.onValue.listen((event) {
      if (_isFirstEvent) {
        _isFirstEvent = false;
        print('Skipping initial event from Firebase');
        return;
      }
      if (event.snapshot.value != null) {
        print('Firebase raw data: ' + event.snapshot.value.toString());
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final song = SelectedSong.fromMap(Map<String, dynamic>.from(data));
        print('Parsed song: ' + song.toString());
        if (_lastTimestamp != song.timestamp) {
          _lastTimestamp = song.timestamp;
          _songController.add(song);
          // Auto-play the song when it's updated
          _playSong(song);
        } else {
          print('Song timestamp unchanged, not playing again.');
        }
      } else {
        print('Firebase snapshot is null');
      }
    });
  }

  // Stop listening to Firebase
  void stopListening() {
    if (_songListener != null) {
      _songListener!.onDisconnect();
      _songListener = null;
    }
    _isListening = false;
  }

  // Play the selected song
  Future<void> _playSong(SelectedSong song) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();
      
      // Stop after 30 seconds (preview duration)
      Timer(const Duration(seconds: 30), () {
        if (_audioPlayer.playing) {
          _audioPlayer.stop();
        }
      });
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  // Play the current song
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  // Pause the current song
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  // Stop the current song
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  // Get current playback state
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  
  // Get current position
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  
  // Get duration
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  // Check if currently playing
  bool get isPlaying => _audioPlayer.playing;

  // Dispose resources
  void dispose() {
    stopListening();
    _audioPlayer.dispose();
    _songController.close();
  }

  AudioPlayer get audioPlayer => _audioPlayer;
} 