import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;
import 'package:piliotto/utils/responsive_util.dart';

class HotController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final ScrollController scrollController = ScrollController();

  RxList<ZerexaVideo> videoList = <ZerexaVideo>[].obs;
  bool isLoadingMore = false;
  String noMore = '';
  RxInt crossAxisCount = 1.obs;

  final List<Map<String, dynamic>> tabs = [
    {'label': '热门', 'sort': 'trending'},
    {'label': '最新', 'sort': 'latest'},
  ];
  RxInt currentTabIndex = 0.obs;

  String get currentSort => tabs[currentTabIndex.value]['sort'] as String;

  @override
  void onInit() {
    super.onInit();
    updateCrossAxisCount();
  }

  void updateCrossAxisCount() {
    try {
      crossAxisCount.value = ResponsiveUtil.calculateCrossAxisCount(baseCount: 1, minCount: 1, maxCount: 3);
    } catch (e) {
      crossAxisCount.value = 1;
    }
  }

  void onTabChanged(int index) {
    if (currentTabIndex.value == index) return;
    currentTabIndex.value = index;
    videoList.clear();
    noMore = '';
    queryHotFeed(type: 'init');
  }

  Future queryHotFeed({String type = 'init'}) async {
    if (isLoadingMore) return;
    isLoadingMore = true;
    if (type == 'init') noMore = '';
    if (noMore == '没有更多了') { isLoadingMore = false; return; }
    try {
      final videos = await _videoRepo.getVideos(sort: currentSort);
      if (type == 'init') {
        videoList.clear();
        videoList.addAll(videos);
      } else {
        videoList.addAll(videos);
      }
      noMore = '没有更多了';
      update();
    } catch (error) {
      noMore = '加载失败';
      update();
    }
    isLoadingMore = false;
  }

  Future onRefresh() async => queryHotFeed(type: 'init');
  Future onLoad() async => queryHotFeed(type: 'onLoad');

  void animateToTop() async {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}
