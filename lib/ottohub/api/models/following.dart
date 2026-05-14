class ZerexaFollowUser {
  final String id;
  final int uid;
  final String username;
  final String? gravatarUrl;
  final int? followerCount;
  final bool? isFollowing;

  ZerexaFollowUser({
    required this.id,
    required this.uid,
    required this.username,
    this.gravatarUrl,
    this.followerCount,
    this.isFollowing,
  });

  factory ZerexaFollowUser.fromJson(Map<String, dynamic> json) => ZerexaFollowUser(
        id: json['id']?.toString() ?? '',
        uid: json['uid'] is int ? json['uid'] : int.tryParse(json['uid']?.toString() ?? '0') ?? 0,
        username: json['username']?.toString() ?? '',
        gravatarUrl: json['gravatar_url']?.toString(),
        followerCount: json['follower_count'] is int ? json['follower_count'] : null,
        isFollowing: json['is_following'] as bool?,
      );
}

class FollowResponse {
  final bool success;
  final bool following;
  final int followerCount;
  final int followingCount;

  FollowResponse({
    required this.success,
    required this.following,
    required this.followerCount,
    required this.followingCount,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) => FollowResponse(
        success: json['success'] == true,
        following: json['following'] == true,
        followerCount: json['follower_count'] is int ? json['follower_count'] : 0,
        followingCount: json['following_count'] is int ? json['following_count'] : 0,
      );
}

class FollowStatusResponse {
  final bool following;
  FollowStatusResponse({required this.following});
  factory FollowStatusResponse.fromJson(Map<String, dynamic> json) =>
      FollowStatusResponse(following: json['following'] == true);
}
