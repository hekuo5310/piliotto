class ZerexaDanmaku {
  final String id;
  final String videoId;
  final String? userId;
  final String? username;
  final String content;
  final double timeSec;
  final String color;
  final String mode;
  final String? createdAt;

  ZerexaDanmaku({
    required this.id,
    required this.videoId,
    this.userId,
    this.username,
    required this.content,
    required this.timeSec,
    required this.color,
    required this.mode,
    this.createdAt,
  });

  factory ZerexaDanmaku.fromJson(Map<String, dynamic> json) {
    return ZerexaDanmaku(
      id: json['id']?.toString() ?? '',
      videoId: json['video_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      username: json['username']?.toString(),
      content: json['content']?.toString() ?? '',
      timeSec: (json['time_sec'] as num?)?.toDouble() ?? 0.0,
      color: json['color']?.toString() ?? '#FFFFFF',
      mode: json['mode']?.toString() ?? 'scroll',
      createdAt: json['created_at']?.toString(),
    );
  }
}
