import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';

class HistoryController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final ScrollController scrollController = ScrollController();
  RxList<ZerexaVideo> historyList = <ZerexaVideo>[].obs;
  RxBool isLoadingMore = false.obs;
  RxBool isLoading = false.obs;
  RxInt crossAxisCount = 1.obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    updateCrossAxisCount();
    queryHistoryList();
  }

  void updateCrossAxisCount() {
    try {
      crossAxisCount.value = ResponsiveUtil.calculateCrossAxisCount(baseCount: 1, minCount: 1, maxCount: 3);
    } catch (e) {
      crossAxisCount.value = 1;
    }
  }

  Future<Map<String, dynamic>> queryHistoryList({String type = 'init'}) async {
    if (userInfo == null) return {'status': false, 'msg': '账号未登录', 'code': -101};
    isLoadingMore.value = true;
    try {
      SmartDialog.showToast('新API暂不支持历史记录');
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
    }
    isLoadingMore.value = false;
    return {'status': true};
  }

  Future onLoad() async => SmartDialog.showToast('没有更多了');
  Future onRefresh() async => queryHistoryList(type: 'onRefresh');
  Future onPauseHistory() async => SmartDialog.showToast('暂不支持');
  Future historyStatus() async {}
  Future onClearHistory() async => SmartDialog.showToast('暂不支持');
  Future<void> delHistory(int kid, String business) async => SmartDialog.showToast('暂不支持');
  Future onDelHistory() async => SmartDialog.showToast('暂不支持');
  Future onDelCheckedHistory() async => SmartDialog.showToast('暂不支持');

  void animateToTop() async {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}
