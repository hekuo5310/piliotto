import '../services/api_service.dart';
import '../models/video.dart';

class VideoService {
  // 视频列表
  static Future<List<ZerexaVideo>> getVideos({
    String? category,
    String sort = 'latest',
  }) async {
    final data = await ApiService.request('/videos', queryParams: {
      if (category != null && category != 'All') 'category': category,
      'sort': sort,
    });
    return (data as List).map((e) => ZerexaVideo.fromJson(e)).toList();
  }

  // 视频详情
  static Future<ZerexaVideo> getVideoDetail(String id) async {
    final data = await ApiService.request('/videos/$id');
    return ZerexaVideo.fromJson(data as Map<String, dynamic>);
  }

  // 推荐视频
  static Future<List<ZerexaVideo>> getRecommend({
    String? userId,
    String? exclude,
    String? category,
  }) async {
    final data = await ApiService.request('/recommend', queryParams: {
      if (userId != null) 'user_id': userId,
      if (exclude != null) 'exclude': exclude,
      if (category != null) 'category': category,
    });
    return (data as List).map((e) => ZerexaVideo.fromJson(e)).toList();
  }

  // 搜索
  static Future<Map<String, dynamic>> search(String q) async {
    final data = await ApiService.request('/search', queryParams: {'q': q});
    return data as Map<String, dynamic>;
  }

  // 点赞/取消点赞
  static Future<VideoLikeResponse> toggleLike(String id) async {
    final data = await ApiService.request('/videos/$id/like',
        method: 'POST', requireToken: true);
    return VideoLikeResponse.fromJson(data as Map<String, dynamic>);
  }

  // 收藏
  static Future<VideoFavoriteResponse> favorite(String id) async {
    final data = await ApiService.request('/videos/$id/favorite',
        method: 'POST', requireToken: true);
    return VideoFavoriteResponse.fromJson(data as Map<String, dynamic>);
  }

  // 取消收藏
  static Future<VideoFavoriteResponse> unfavorite(String id) async {
    final data = await ApiService.request('/videos/$id/favorite',
        method: 'DELETE', requireToken: true);
    return VideoFavoriteResponse.fromJson(data as Map<String, dynamic>);
  }

  // 查询收藏状态
  static Future<bool> getFavoritedStatus(String id) async {
    final data = await ApiService.request('/videos/$id/favorited',
        requireToken: true);
    return (data as Map<String, dynamic>)['favorited'] == true;
  }

  // 投币
  static Future<VideoCoinResponse> coin(String id, {int amount = 1}) async {
    final data = await ApiService.request('/videos/$id/coin',
        method: 'POST', body: {'amount': amount}, requireToken: true);
    return VideoCoinResponse.fromJson(data as Map<String, dynamic>);
  }

  // 记录观看
  static Future<void> watch(String id,
      {required int watchSeconds, required int videoSeconds}) async {
    await ApiService.request('/videos/$id/watch',
        method: 'POST',
        body: {'watch_seconds': watchSeconds, 'video_seconds': videoSeconds});
  }

  // 删除视频
  static Future<void> deleteVideo(String id) async {
    await ApiService.request('/videos/$id', method: 'DELETE', requireToken: true);
  }

  // 编辑视频
  static Future<void> updateVideo(
    String id, {
    required String title,
    required String description,
    required String category,
    String? sourceUrl,
  }) async {
    await ApiService.request('/videos/$id',
        method: 'PUT',
        requireToken: true,
        body: {
          'title': title,
          'description': description,
          'category': category,
          if (sourceUrl != null) 'source_url': sourceUrl,
        });
  }

  // 举报视频
  static Future<void> reportVideo(String id,
      {required String reason, String? details}) async {
    await ApiService.request('/videos/$id/report',
        method: 'POST',
        requireToken: true,
        body: {
          'reason': reason,
          if (details != null) 'details': details,
        });
  }

  // 当前用户视频列表
  static Future<List<ZerexaVideo>> getMyVideos() async {
    final data =
        await ApiService.request('/users/me/videos', requireToken: true);
    return (data as List).map((e) => ZerexaVideo.fromJson(e)).toList();
  }

  // 当前用户收藏列表
  static Future<List<ZerexaVideo>> getMyFavorites() async {
    final data =
        await ApiService.request('/users/me/favorites', requireToken: true);
    return (data as List).map((e) => ZerexaVideo.fromJson(e)).toList();
  }

  // 某用户视频列表（公开）
  static Future<List<ZerexaVideo>> getUserVideos(String userId) async {
    final data = await ApiService.request('/users/$userId');
    final json = data as Map<String, dynamic>;
    final videos = json['videos'] as List? ?? [];
    return videos.map((e) => ZerexaVideo.fromJson(e)).toList();
  }
}
