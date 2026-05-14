import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';

class VideoReplyController extends GetxController {
  VideoReplyController(this.vid);

  String vid;

  List<ReplyItemModel> replyList = <ReplyItemModel>[];
  int currentPage = 0;
  bool isLoadingMore = false;
  bool hasLoaded = false;
  String noMore = '';
  int ps = 12;
  int count = 0;

  Box setting = GStrorage.setting;
  final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

  void updateVid(int newVid) {
    final newVidStr = newVid.toString();
    if (vid != newVidStr) {
      vid = newVidStr;
      replyList.clear();
      currentPage = 0;
      hasLoaded = false;
      noMore = '';
      count = 0;
    }
  }

  Future queryReplyList({String type = 'init'}) async {
    if (isLoadingMore) return;
    isLoadingMore = true;
    if (type == 'init') { currentPage = 0; noMore = ''; }
    if (noMore == '没有更多了') { isLoadingMore = false; return; }
    try {
      final result = await _commentRepo.getVideoComments(
        videoId: vid,
        offset: currentPage * ps,
        num: ps,
      );
      final List<ReplyItemModel> replyItems = result.replies;
      if (type == 'init') {
        count = replyItems.length;
        replyList = replyItems;
      } else {
        replyList.addAll(replyItems);
      }
      if (!result.hasMore) { noMore = '没有更多了'; } else { currentPage++; noMore = ''; }
      hasLoaded = true;
      update();
    } catch (e) {
      getLogger().e('获取评论异常: ${e.toString()}');
      noMore = '获取评论失败';
      update();
    }
    isLoadingMore = false;
  }

  Future onLoad() async => queryReplyList(type: 'onLoad');

  Future<List<ReplyItemModel>> queryChildComments(String parentId) async {
    try {
      final result = await _commentRepo.getVideoComments(
        videoId: vid,
        parentId: parentId,
        offset: 0,
        num: ps,
      );
      return result.replies;
    } catch (e) {
      getLogger().e('获取二级评论异常: ${e.toString()}');
      return [];
    }
  }
}
