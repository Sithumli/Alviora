class SelectedSong {
  final String artist;
  final String audioUrl;
  final String image;
  final int timestamp;
  final String title;

  SelectedSong({
    required this.artist,
    required this.audioUrl,
    required this.image,
    required this.timestamp,
    required this.title,
  });

  factory SelectedSong.fromMap(Map<String, dynamic> map) {
    return SelectedSong(
      artist: map['artist'] ?? '',
      audioUrl: map['audio_url'] ?? '',
      image: map['image'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      title: map['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'artist': artist,
      'audio_url': audioUrl,
      'image': image,
      'timestamp': timestamp,
      'title': title,
    };
  }

  @override
  String toString() {
    return 'SelectedSong(artist: $artist, audioUrl: $audioUrl, image: $image, timestamp: $timestamp, title: $title)';
  }
} 