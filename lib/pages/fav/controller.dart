import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/responsive_util.dart';

final _logger = getLogger();

class FavController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final ScrollController scrollController = ScrollController();

  RxList<ZerexaVideo> favoriteList = <ZerexaVideo>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = false.obs;
  RxInt crossAxisCount = 1.obs;

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

  Future<void> queryFavorites({bool isLoadMore = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final videos = await _videoRepo.getMyFavorites();
      favoriteList.value = videos;
    } catch (e) {
      _logger.e('获取收藏列表失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onLoad() async {}
  Future<void> onRefresh() async => queryFavorites();

  Future<void> removeFavorite(String id) async {
    try {
      await _videoRepo.unfavorite(id);
      favoriteList.removeWhere((v) => v.id == id);
    } catch (e) {
      _logger.e('取消收藏失败: $e');
    }
  }

  void animateToTop() async {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}
