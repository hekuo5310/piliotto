import 'package:piliotto/ottohub/api/models/following.dart';
import 'package:piliotto/ottohub/models/member/info.dart';
import 'base_repository.dart';

class UserProfileInfo {
  final String? coverUrl;
  final int followingCount;
  final int fansCount;

  UserProfileInfo({
    this.coverUrl,
    this.followingCount = 0,
    this.fansCount = 0,
  });
}

abstract class IUserRepository {
  Future<MemberInfoModel> getUserDetail({required String userId, CacheConfig? cacheConfig});
  Future<UserProfileInfo> getUserProfileInfo({required String userId});
  Future<FollowStatusResponse> getFollowStatus({required String userId});
  Future<FollowResponse> followUser({required String userId});
  Future<FollowResponse> unfollowUser({required String userId});
}
