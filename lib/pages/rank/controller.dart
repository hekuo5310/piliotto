import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/utils/responsive_util.dart';

class RankController extends GetxController with GetTickerProviderStateMixin {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  late TabController tabController;
  final ScrollController scrollController = ScrollController();

  RxList<ZerexaVideo> videoList = <ZerexaVideo>[].obs;
  RxBool isLoading = false.obs;
  RxInt crossAxisCount = 1.obs;

  final List<Map<String, dynamic>> tabs = [
    {'label': '热门', 'sort': 'trending'},
    {'label': '最新', 'sort': 'latest'},
  ];

  RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(_onTabChanged);
    updateCrossAxisCount();
    loadVideos();
  }

  void _onTabChanged() {
    if (tabController.index != currentTabIndex.value) {
      currentTabIndex.value = tabController.index;
      loadVideos();
    }
  }

  void updateCrossAxisCount() {
    try {
      crossAxisCount.value = ResponsiveUtil.calculateCrossAxisCount(baseCount: 1, minCount: 1, maxCount: 3);
    } catch (e) {
      crossAxisCount.value = 1;
    }
  }

  Future<void> loadVideos() async {
    isLoading.value = true;
    try {
      final sort = tabs[currentTabIndex.value]['sort'] as String;
      final videos = await _videoRepo.getVideos(sort: sort);
      videoList.value = videos;
    } catch (e) {
      getLogger().e('加载失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async => loadVideos();

  void animateToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
