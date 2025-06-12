class Detection {
  final String title;
  final String time;
  final bool urgency;
  final String action;
  final String imageAsset;
  final bool isRecent;

  Detection({
    required this.title,
    required this.time,
    required this.urgency,
    required this.action,
    required this.imageAsset,
    required this.isRecent,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      title: json['title'],
      time: json['time'],
      urgency: json['urgency'],
      action: json['action'],
      imageAsset: json['imageAsset'],
      isRecent: json['isRecent'],
    );
  }
}
