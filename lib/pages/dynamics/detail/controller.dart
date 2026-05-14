import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class DynamicDetailController extends GetxController {
  DynamicDetailController(this.oid);
  dynamic oid;
  dynamic item;
  RxBool isLoadingMore = false.obs;
  RxString noMore = ''.obs;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  RxInt acount = 0.obs;
  final ScrollController scrollController = ScrollController();
  Box setting = GStrorage.setting;
  Rxn<ReplyItemModel> replyingTo = Rxn<ReplyItemModel>();
  RxInt parentBcid = 0.obs;

  @override
  void onInit() {
    super.onInit();
    item = Get.arguments['item'];
    acount.value = int.tryParse(item?.modules?.moduleStat?.comment?.count ?? '0') ?? 0;
  }

  Future<Map<String, dynamic>> queryReplyList({String reqType = 'init'}) async {
    if (reqType == 'init') replyList.clear();
    isLoadingMore.value = true;
    SmartDialog.showToast('新API暂不支持动态评论');
    noMore.value = '暂不支持';
    isLoadingMore.value = false;
    return {'status': true};
  }

  void setReplyingTo(ReplyItemModel? replyItem, {int? parent}) {
    replyingTo.value = replyItem;
    parentBcid.value = parent ?? replyItem?.rpid ?? 0;
  }

  void clearReplyingTo() {
    replyingTo.value = null;
    parentBcid.value = 0;
  }

  void onReplySuccess() {
    clearReplyingTo();
    queryReplyList(reqType: 'init');
    acount.value++;
  }
}
