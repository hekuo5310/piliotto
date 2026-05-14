import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/ottohub/models/member/archive.dart';
import 'base_repository.dart';

abstract class IVideoRepository {
  Future<List<ZerexaVideo>> getVideos({String? category, String sort = 'latest'});
  Future<ZerexaVideo> getVideoDetail(String id, {CacheConfig? cacheConfig});
  Future<List<ZerexaVideo>> getRecommend({String? userId, String? exclude, String? category});
  Future<Map<String, dynamic>> search(String q);
  Future<VideoLikeResponse> toggleLike(String id);
  Future<VideoFavoriteResponse> favorite(String id);
  Future<VideoFavoriteResponse> unfavorite(String id);
  Future<bool> getFavoritedStatus(String id);
  Future<VideoCoinResponse> coin(String id, {int amount = 1});
  Future<void> watch(String id, {required int watchSeconds, required int videoSeconds});
  Future<void> deleteVideo(String id);
  Future<void> updateVideo(String id, {required String title, required String description, required String category, String? sourceUrl});
  Future<void> reportVideo(String id, {required String reason, String? details});
  Future<List<ZerexaVideo>> getMyVideos();
  Future<List<ZerexaVideo>> getMyFavorites();
  Future<List<ZerexaVideo>> getUserVideos(String userId);
  Future<List<VListItemModel>> getUserVideoList({required String userId});
}
