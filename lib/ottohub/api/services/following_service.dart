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

  static Future<List<Map<String, dynamic>>> getMyFollowing() async {
    final data = await ApiService.request('/users/me/following', requireToken: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getMyFollowers() async {
    final data = await ApiService.request('/users/me/followers', requireToken: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getUserFollowers(String userId) async {
    final data = await ApiService.request('/users/$userId/followers');
    return (data as List).cast<Map<String, dynamic>>();
  }
}
