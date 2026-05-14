import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/services/loggeer.dart';

final _logger = getLogger();

class VideoSearchController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchInputController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  RxList<ZerexaVideo> videoList = <ZerexaVideo>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxString currentKeyword = ''.obs;
  RxInt crossAxisCount = 1.obs;
  RxString errorMessage = ''.obs;
  RxBool hasError = false.obs;

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

  Future<void> searchVideos(String keyword, {bool isLoadMore = false}) async {
    if (keyword.isEmpty) return;
    if (!isLoadMore) {
      isLoading.value = true;
      currentKeyword.value = keyword;
      errorMessage.value = '';
      hasError.value = false;
    } else {
      isLoadingMore.value = true;
    }
    try {
      final result = await _videoRepo.search(keyword);
      final videos = (result['videos'] as List? ?? [])
          .map((e) => ZerexaVideo.fromJson(e as Map<String, dynamic>))
          .toList();
      if (isLoadMore) {
        videoList.addAll(videos);
      } else {
        videoList.value = videos;
      }
    } catch (e) {
      _logger.w('搜索失败: $e');
      if (!isLoadMore) {
        errorMessage.value = '搜索失败，请稍后重试';
        hasError.value = true;
        videoList.clear();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> onLoad() async {}
  Future<void> onRefresh() async {
    if (currentKeyword.value.isNotEmpty) await searchVideos(currentKeyword.value);
  }

  void clearSearchResult() {
    videoList.clear();
    currentKeyword.value = '';
    searchInputController.clear();
    errorMessage.value = '';
    hasError.value = false;
  }

  void retrySearch() {
    if (currentKeyword.value.isNotEmpty) searchVideos(currentKeyword.value);
  }

  void animateToTop() async {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}
