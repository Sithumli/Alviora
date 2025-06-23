import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MeditationApp());
}

class MeditationApp extends StatelessWidget {
  final int durationMinutes;
  final String meditationType;
  const MeditationApp({Key? key, this.durationMinutes = 5, this.meditationType = "Meditation"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MeditationTimerScreen(durationMinutes: durationMinutes, meditationType: meditationType);
  }
}

class MeditationTimerScreen extends StatefulWidget {
  final int durationMinutes;
  final String meditationType;
  const MeditationTimerScreen({Key? key, this.durationMinutes = 5, this.meditationType = "Meditation"}) : super(key: key);

  @override
  _MeditationTimerScreenState createState() => _MeditationTimerScreenState();
}

class _MeditationTimerScreenState extends State<MeditationTimerScreen> {
  Timer? _timer;
  late int _minutes;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _minutes = widget.durationMinutes;
    _seconds = 0;
  }

  void _startTimer() {
    if (!_isRunning && !_isPaused) {
      setState(() {
        _isRunning = true;
      });
    }

    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else if (_minutes > 0) {
          _minutes--;
          _seconds = 59;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _playCompletionSound();
          // Timer completed
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _minutes = widget.durationMinutes;
      _seconds = 0;
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _showOptions() {
    // Options menu functionality
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.timer, color: Colors.blue),
              title: Text('Set Timer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.music_note, color: Colors.blue),
              title: Text('Background Sounds'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue),
              title: Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playCompletionSound() async {
    try {
      await _player.setAsset('assets/sounds/notification.mp3');
      await _player.play();
    } catch (e) {
      print('Error playing completion sound: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F0FF),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Header with title and lotus icon
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.spa,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      widget.meditationType,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Go Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 40),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.blue.shade600),
                    label: Text(
                      'Go Back',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade300, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ),

              Spacer(),

              // Timer Display
              Container(
                child: Column(
                  children: [
                    // Minutes
                    Text(
                      '${_minutes.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade600,
                        height: 0.9,
                      ),
                    ),
                    // Seconds
                    Text(
                      '${_seconds.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade600,
                        height: 0.9,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Options Button
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    child: IconButton(
                      onPressed: _showOptions,
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.blue.shade600,
                        size: 28,
                      ),
                    ),
                  ),

                  // Play/Pause Button
                  Container(
                    width: 90,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    child: IconButton(
                      onPressed: _isRunning && !_isPaused ? _pauseTimer : _startTimer,
                      icon: Icon(
                        _isRunning && !_isPaused ? Icons.pause : Icons.play_arrow,
                        color: Colors.blue.shade600,
                        size: 32,
                      ),
                    ),
                  ),

                  // Skip/Reset Button
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    child: IconButton(
                      onPressed: _resetTimer,
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.blue.shade600,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}