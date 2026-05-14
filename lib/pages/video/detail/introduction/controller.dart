import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/repositories/i_user_repository.dart';
import 'package:piliotto/pages/video/detail/controller.dart';
import 'package:piliotto/pages/video/detail/reply/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:share_plus/share_plus.dart';

import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;

class VideoIntroController extends GetxController {
  VideoIntroController({required this.vid});
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final IUserRepository _userRepo = Get.find<IUserRepository>();
  String vid;
  Rxn<ZerexaVideo> videoDetail = Rxn<ZerexaVideo>();
  RxInt follower = 0.obs;
  RxBool hasLike = false.obs;
  RxBool hasFav = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  Box setting = GStrorage.setting;
  bool userLogin = false;
  RxBool followStatus = false.obs;
  dynamic userInfo;
  String heroTag = '';
  PersistentBottomSheetController? bottomSheetController;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    heroTag = Get.arguments?['heroTag'] ?? '';
    userLogin = userInfo != null;
  }

  Future queryVideoIntro() async {
    try {
      videoDetail.value = await _videoRepo.getVideoDetail(vid);
      final VideoDetailController videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
      videoDetailCtr.tabs.value = ['简介', '评论'];
      videoDetailCtr.cover.value = videoDetail.value?.coverUrl ?? '';
      queryUserStat();
    } catch (e) {
      SmartDialog.showToast('获取视频详情失败：${e.toString()}');
    }
    if (userLogin) {
      queryHasLikeVideo();
      queryHasFavVideo();
      queryFollowStatus();
    }
  }

  int get danmakuCount {
    try {
      return Get.find<VideoDetailController>(tag: heroTag).danmakuCount;
    } catch (e) {
      return 0;
    }
  }

  Future queryUserStat() async {
    final authorId = videoDetail.value?.id;
    if (authorId == null) return;
    try {
      final memberInfo = await _userRepo.getUserDetail(userId: authorId);
      follower.value = memberInfo.fans ?? 0;
    } catch (e) {
      getLogger().e('获取用户粉丝数失败: $e');
    }
  }

  Future queryHasLikeVideo() async {
    try {
      // 新API无直接获取点赞状态接口，默认false
      hasLike.value = false;
    } catch (_) {}
  }

  Future queryHasFavVideo() async {
    try {
      hasFav.value = await _videoRepo.getFavoritedStatus(vid);
    } catch (_) {
      hasFav.value = false;
    }
  }

  Future actionOneThree() async {
    if (userInfo == null) { SmartDialog.showToast('账号未登录'); return; }
    try {
      if (!hasLike.value) {
        await _videoRepo.toggleLike(vid);
        hasLike.value = true;
      }
      if (!hasFav.value) {
        await _videoRepo.favorite(vid);
        hasFav.value = true;
      }
      SmartDialog.showToast('操作成功');
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  Future actionLikeVideo() async {
    if (userInfo == null) { SmartDialog.showToast('账号未登录'); return; }
    try {
      final res = await _videoRepo.toggleLike(vid);
      hasLike.value = res.liked;
      SmartDialog.showToast(res.liked ? '点赞成功' : '取消赞');
      videoDetail.value = await _videoRepo.getVideoDetail(vid);
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  Future<void> actionFavVideo({String type = 'choose'}) async {
    if (userInfo == null) { SmartDialog.showToast('账号未登录'); return; }
    try {
      if (!hasFav.value) {
        await _videoRepo.favorite(vid);
        hasFav.value = true;
        SmartDialog.showToast('收藏成功');
      } else {
        await _videoRepo.unfavorite(vid);
        hasFav.value = false;
        SmartDialog.showToast('取消收藏');
      }
      videoDetail.value = await _videoRepo.getVideoDetail(vid);
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  Future actionShareVideo() async {
    return SharePlus.instance.share(ShareParams(
      text: '${videoDetail.value?.title ?? ''} - https://video.zerexa.cn/video/$vid',
    ));
  }

  Future queryFollowStatus() async {
    if (!userLogin) { followStatus.value = false; return; }
    try {
      final authorId = videoDetail.value?.id;
      if (authorId == null) return;
      final result = await _userRepo.getFollowStatus(userId: authorId);
      followStatus.value = result.following;
    } catch (e) {
      followStatus.value = false;
    }
  }

  Future actionRelationMod() async {
    feedBack();
    if (userInfo == null) { SmartDialog.showToast('账号未登录'); return; }
    final authorId = videoDetail.value?.id;
    if (authorId == null) return;
    final bool currentStatus = followStatus.value;
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(currentStatus ? '取消关注UP主?' : '关注UP主?'),
          actions: [
            TextButton(onPressed: () => SmartDialog.dismiss(), child: Text('点错了', style: TextStyle(color: Theme.of(context).colorScheme.outline))),
            TextButton(
              onPressed: () async {
                try {
                  if (currentStatus) {
                    await _userRepo.unfollowUser(userId: authorId);
                  } else {
                    await _userRepo.followUser(userId: authorId);
                  }
                  followStatus.value = !currentStatus;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(currentStatus ? '取消关注成功' : '关注成功'),
                      duration: const Duration(seconds: 2),
                      showCloseIcon: true,
                    ));
                  }
                } catch (e) {
                  SmartDialog.showToast('操作失败：${e.toString()}');
                }
                SmartDialog.dismiss();
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  Future switchVideo(String newVid, String? cover) async {
    final VideoDetailController videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    videoDetailCtr
      ..vid = newVid
      ..cover.value = cover ?? ''
      ..getVideoDetail();
    try {
      final VideoReplyController videoReplyCtr = Get.find<VideoReplyController>(tag: heroTag);
      videoReplyCtr.updateVid(int.tryParse(newVid) ?? 0);
      videoReplyCtr.queryReplyList(type: 'init');
    } catch (_) {}
    vid = newVid;
    await queryVideoIntro();
  }

  void nextPlay() {}
  void setFollowGroup() => SmartDialog.showToast('暂不支持此功能');

  void oneThreeDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('是否一键点赞和收藏'),
        actions: [
          TextButton(onPressed: () => navigator!.pop(), child: Text('取消', style: TextStyle(color: Theme.of(Get.context!).colorScheme.outline))),
          TextButton(onPressed: () async { actionOneThree(); navigator!.pop(); }, child: const Text('确认')),
        ],
      ),
    );
  }
}
