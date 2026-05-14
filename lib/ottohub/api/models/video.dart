class ZerexaVideo {
  final String id;
  final String title;
  final String? description;
  final int views;
  final int likes;
  final String? authorUsername;
  final int? authorUid;
  final String? streamUrl;
  final String? coverUrl;
  final String? status;
  final String? category;
  final String? sourceUrl;
  final String? createdAt;

  ZerexaVideo({
    required this.id,
    required this.title,
    this.description,
    this.views = 0,
    this.likes = 0,
    this.authorUsername,
    this.authorUid,
    this.streamUrl,
    this.coverUrl,
    this.status,
    this.category,
    this.sourceUrl,
    this.createdAt,
  });

  factory ZerexaVideo.fromJson(Map<String, dynamic> json) {
    return ZerexaVideo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      views: _toInt(json['views']),
      likes: _toInt(json['likes']),
      authorUsername: json['author_username']?.toString(),
      authorUid: _toInt(json['author_uid']),
      streamUrl: json['stream_url']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      status: json['status']?.toString(),
      category: json['category']?.toString(),
      sourceUrl: json['source_url']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

class VideoLikeResponse {
  final bool liked;
  VideoLikeResponse({required this.liked});
  factory VideoLikeResponse.fromJson(Map<String, dynamic> json) =>
      VideoLikeResponse(liked: json['liked'] == true);
}

class VideoFavoriteResponse {
  final bool success;
  final bool favorited;
  VideoFavoriteResponse({required this.success, required this.favorited});
  factory VideoFavoriteResponse.fromJson(Map<String, dynamic> json) =>
      VideoFavoriteResponse(
        success: json['success'] == true,
        favorited: json['favorited'] == true,
      );
}

class VideoCoinResponse {
  final bool success;
  final int coinsGiven;
  final int remaining;
  VideoCoinResponse({required this.success, required this.coinsGiven, required this.remaining});
  factory VideoCoinResponse.fromJson(Map<String, dynamic> json) =>
      VideoCoinResponse(
        success: json['success'] == true,
        coinsGiven: json['coinsGiven'] is int ? json['coinsGiven'] : 0,
        remaining: json['remaining'] is int ? json['remaining'] : 0,
      );
}
