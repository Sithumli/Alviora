import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/selected_song_model.dart';
import '../services/music_service.dart';

class MusicPreviewCard extends StatefulWidget {
  final SelectedSong song;
  final VoidCallback? onClose;

  const MusicPreviewCard({
    super.key,
    required this.song,
    this.onClose,
  });

  @override
  State<MusicPreviewCard> createState() => _MusicPreviewCardState();
}

class _MusicPreviewCardState extends State<MusicPreviewCard>
    with TickerProviderStateMixin {
  final MusicService _musicService = MusicService();
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  Timer? _positionTimer;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Listen to audio player state
    _musicService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
    
    // Listen to position updates
    _musicService.positionStream.listen((position) {
      if (mounted && position != null) {
        setState(() {
          _position = position;
        });
      }
    });
    
    // Listen to duration updates
    _musicService.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });
    
    // Start position timer for smooth progress updates
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying && mounted) {
        setState(() {});
      }
    });

    // Listen for song completion
    _musicService.audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (mounted) {
          _close();
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _positionTimer?.cancel();
    super.dispose();
  }

  void _playPause() {
    if (_isPlaying) {
      _musicService.pause();
    } else {
      _musicService.play();
    }
  }

  void _stop() {
    _musicService.stop();
  }

  void _close() {
    _musicService.stop();
    _fadeController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _scaleController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox.expand(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E3A8A),
                      const Color(0xFF3B82F6),
                      const Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Music Preview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _close,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              // Album Art
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    widget.song.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.music_note,
                                          size: 100,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Song Info
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Column(
                                  children: [
                                    Text(
                                      widget.song.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget.song.artist,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Progress Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Colors.white,
                                        inactiveTrackColor: Colors.white30,
                                        thumbColor: Colors.white,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 8,
                                        ),
                                        trackHeight: 4,
                                      ),
                                      child: Slider(
                                        value: _duration.inMilliseconds > 0
                                            ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                                            : 0.0,
                                        onChanged: (value) {
                                          // Seek functionality could be added here
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(_position),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(_duration),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Control Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Stop Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      onPressed: _stop,
                                      icon: const Icon(
                                        Icons.stop,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      iconSize: 30,
                                      padding: const EdgeInsets.all(15),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  // Play/Pause Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: _playPause,
                                      icon: Icon(
                                        _isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: const Color(0xFF3B82F6),
                                        size: 40,
                                      ),
                                      iconSize: 40,
                                      padding: const EdgeInsets.all(20),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  // Cancel Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      onPressed: _close,
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      iconSize: 30,
                                      padding: const EdgeInsets.all(15),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}