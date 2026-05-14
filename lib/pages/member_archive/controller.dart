import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/ottohub/models/member/archive.dart';

class MemberArchiveController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final ScrollController scrollController = ScrollController();
  late String mid;
  RxList<VListItemModel> archivesList = <VListItemModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    mid = Get.parameters['mid'] ?? '';
  }

  Future<void> getMemberArchive(String type) async {
    if (isLoading.value) return;
    isLoading.value = true;
    if (type == 'init') archivesList.clear();
    try {
      final items = await _videoRepo.getUserVideoList(userId: mid);
      if (type == 'init') {
        archivesList.value = items;
      } else {
        archivesList.addAll(items);
      }
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
    }
    isLoading.value = false;
  }

  Future onLoad() async => getMemberArchive('onLoad');
}
