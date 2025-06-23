import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';

class DeepBreathing extends StatelessWidget {
  final int durationMinutes;
  const DeepBreathing({Key? key, this.durationMinutes = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DeepBreathingTimerScreen(durationMinutes: durationMinutes);
  }
}

class DeepBreathingTimerScreen extends StatefulWidget {
  final int durationMinutes;
  const DeepBreathingTimerScreen({Key? key, this.durationMinutes = 5}) : super(key: key);

  @override
  _DeepBreathingTimerScreenState createState() => _DeepBreathingTimerScreenState();
}

class _DeepBreathingTimerScreenState extends State<DeepBreathingTimerScreen> {
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

  Future<void> _playCompletionSound() async {
    try {
      await _player.setAsset('assets/sounds/notification.mp3');
      await _player.play();
    } catch (e) {
      print('Error playing completion sound: $e');
    }
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
              leading: Icon(Icons.waves, color: Colors.blue),
              title: Text('Breathing Rhythm'),
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
              // Header with title and breathing icon
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
                      Icons.waves,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Deep Breathing',
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A90E2),
                          width: 2,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Color(0xFF4A90E2),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Go Back',
                            style: TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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