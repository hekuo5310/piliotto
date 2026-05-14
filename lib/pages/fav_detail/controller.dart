import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/services/loggeer.dart';

final _logger = getLogger();

class FavDetailController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  RxString title = ''.obs;
  RxList<ZerexaVideo> favList = <ZerexaVideo>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = false.obs;
  RxString loadingText = '加载中...'.obs;

  @override
  void onInit() {
    super.onInit();
    title.value = Get.parameters['title'] ?? '我的收藏';
    queryFavorites();
  }

  Future<void> queryFavorites({bool isLoadMore = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final videos = await _videoRepo.getMyFavorites();
      favList.value = videos;
      loadingText.value = '没有更多了';
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
      favList.removeWhere((v) => v.id == id);
    } catch (e) {
      _logger.e('取消收藏失败: $e');
    }
  }
}
