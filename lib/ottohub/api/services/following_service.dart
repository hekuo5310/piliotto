import '../services/api_service.dart';
import '../models/following.dart';

class FollowingService {
  static Future<FollowResponse> followUser(String userId) async {
    final data = await ApiService.request('/users/$userId/follow',
        method: 'POST', requireToken: true);
    return FollowResponse.fromJson(data as Map<String, dynamic>);
  }

  static Future<FollowResponse> unfollowUser(String userId) async {
    final data = await ApiService.request('/users/$userId/follow',
        method: 'DELETE', requireToken: true);
    return FollowResponse.fromJson(data as Map<String, dynamic>);
  }

  static Future<FollowStatusResponse> getFollowStatus(String userId) async {
    final data = await ApiService.request('/users/$userId/follow-status',
        requireToken: true);
    return FollowStatusResponse.fromJson(data as Map<String, dynamic>);
  }
}
