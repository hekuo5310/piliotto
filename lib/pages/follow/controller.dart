import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/ottohub/api/models/following.dart' show ZerexaFollowUser;
import 'package:piliotto/utils/storage.dart';

class FollowController extends GetxController {
  Box userInfoCache = GStrorage.userInfo;
  RxList<ZerexaFollowUser> followList = <ZerexaFollowUser>[].obs;
  late String mid;
  late String name;
  dynamic userInfo;
  RxString loadingText = '暂不支持'.obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    mid = Get.parameters['mid'] ?? userInfo?.mid?.toString() ?? '';
    name = Get.parameters['name'] != null
        ? Uri.decodeComponent(Get.parameters['name']!)
        : userInfo?.uname ?? '';
    isLoading.value = false;
  }

  Future<void> queryFollowings({bool isLoadMore = false}) async {}
  Future<void> onLoad() async {}
  Future<void> onRefresh() async {}
}
