import '../api/services/video_service.dart';
import '../api/models/video.dart';
import '../models/member/archive.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_video_repository.dart';

class OttohubVideoRepository extends BaseRepository implements IVideoRepository {
  @override
  Future<List<ZerexaVideo>> getVideos({String? category, String sort = 'latest'}) {
    return withCache(
      'getVideos_${category}_$sort',
      () => VideoService.getVideos(category: category, sort: sort),
    );
  }

  @override
  Future<ZerexaVideo> getVideoDetail(String id, {CacheConfig? cacheConfig}) {
    return withCache(
      'getVideoDetail_$id',
      () => VideoService.getVideoDetail(id),
      cacheConfig: cacheConfig ?? const CacheConfig(duration: Duration(minutes: 2)),
    );
  }

  @override
  Future<List<ZerexaVideo>> getRecommend({String? userId, String? exclude, String? category}) {
    return VideoService.getRecommend(userId: userId, exclude: exclude, category: category);
  }

  @override
  Future<Map<String, dynamic>> search(String q) => VideoService.search(q);

  @override
  Future<VideoLikeResponse> toggleLike(String id) {
    invalidateCache('getVideoDetail_$id');
    return VideoService.toggleLike(id);
  }

  @override
  Future<VideoFavoriteResponse> favorite(String id) {
    invalidateCache('getVideoDetail_$id');
    return VideoService.favorite(id);
  }

  @override
  Future<VideoFavoriteResponse> unfavorite(String id) {
    invalidateCache('getVideoDetail_$id');
    return VideoService.unfavorite(id);
  }

  @override
  Future<bool> getFavoritedStatus(String id) => VideoService.getFavoritedStatus(id);

  @override
  Future<VideoCoinResponse> coin(String id, {int amount = 1}) => VideoService.coin(id, amount: amount);

  @override
  Future<void> watch(String id, {required int watchSeconds, required int videoSeconds}) =>
      VideoService.watch(id, watchSeconds: watchSeconds, videoSeconds: videoSeconds);

  @override
  Future<void> deleteVideo(String id) {
    invalidateCache('getVideoDetail_$id');
    return VideoService.deleteVideo(id);
  }

  @override
  Future<void> updateVideo(String id, {required String title, required String description, required String category, String? sourceUrl}) {
    invalidateCache('getVideoDetail_$id');
    return VideoService.updateVideo(id, title: title, description: description, category: category, sourceUrl: sourceUrl);
  }

  @override
  Future<void> reportVideo(String id, {required String reason, String? details}) =>
      VideoService.reportVideo(id, reason: reason, details: details);

  @override
  Future<List<ZerexaVideo>> getMyVideos() => VideoService.getMyVideos();

  @override
  Future<List<ZerexaVideo>> getMyFavorites() => VideoService.getMyFavorites();

  @override
  Future<List<ZerexaVideo>> getUserVideos(String userId) => VideoService.getUserVideos(userId);

  @override
  Future<List<VListItemModel>> getUserVideoList({required String userId}) async {
    final videos = await VideoService.getUserVideos(userId);
    return videos.map((v) => VListItemModel(
      title: v.title,
      pic: v.coverUrl,
      description: v.description,
      play: v.views,
      review: v.likes,
      author: v.authorUsername,
      mid: v.authorUid,
    )).toList();
  }
}
