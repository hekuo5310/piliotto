import '../api/services/following_service.dart';
import '../api/services/api_service.dart';
import '../api/models/following.dart';
import '../models/member/info.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_user_repository.dart';

class OttohubUserRepository extends BaseRepository implements IUserRepository {
  @override
  Future<MemberInfoModel> getUserDetail({required String userId, CacheConfig? cacheConfig}) {
    return withCache(
      'getUserDetail_$userId',
      () async {
        final data = await ApiService.request('/users/$userId');
        final json = data as Map<String, dynamic>;
        final user = json['user'] as Map<String, dynamic>? ?? json;
        return MemberInfoModel(
          mid: user['uid'] is int ? user['uid'] : int.tryParse(user['uid']?.toString() ?? '0'),
          name: user['username']?.toString() ?? '',
          sign: user['bio']?.toString() ?? '',
          face: user['gravatar_url']?.toString() ?? '',
          fans: user['follower_count'] is int ? user['follower_count'] : 0,
          attention: user['following_count'] is int ? user['following_count'] : 0,
          archiveCount: (json['videos'] as List?)?.length ?? 0,
        );
      },
      cacheConfig: cacheConfig ?? const CacheConfig(duration: Duration(minutes: 5)),
    );
  }

  @override
  Future<UserProfileInfo> getUserProfileInfo({required String userId}) async {
    final data = await ApiService.request('/users/$userId');
    final json = data as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return UserProfileInfo(
      followingCount: user['following_count'] is int ? user['following_count'] : 0,
      fansCount: user['follower_count'] is int ? user['follower_count'] : 0,
    );
  }

  @override
  Future<FollowStatusResponse> getFollowStatus({required String userId}) =>
      FollowingService.getFollowStatus(userId);

  @override
  Future<FollowResponse> followUser({required String userId}) {
    invalidateCache('getUserDetail_$userId');
    return FollowingService.followUser(userId);
  }

  @override
  Future<FollowResponse> unfollowUser({required String userId}) {
    invalidateCache('getUserDetail_$userId');
    return FollowingService.unfollowUser(userId);
  }
}
