import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_dynamics_repository.dart';
import 'package:piliotto/ottohub/models/dynamics/result.dart';

class MemberDynamicsController extends GetxController {
  final IDynamicsRepository _dynamicsRepo = Get.find<IDynamicsRepository>();
  final ScrollController scrollController = ScrollController();
  late String mid;
  RxList<DynamicItemModel> dynamicsList = <DynamicItemModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    mid = Get.parameters['mid'] ?? '';
  }

  Future<Map<String, dynamic>> getMemberDynamic(String type) async {
    if (isLoading.value) return {};
    if (type == 'onRefresh') dynamicsList.clear();
    isLoading.value = true;
    try {
      final list = await _dynamicsRepo.getUserDynamics(userId: mid);
      if (type == 'onRefresh') {
        dynamicsList.value = list;
      } else {
        dynamicsList.addAll(list);
      }
      return {'status': 'success'};
    } catch (e) {
      return {'status': 'fail', 'message': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  Future onLoad() async => getMemberDynamic('onLoad');
}
