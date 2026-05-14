import 'package:piliotto/ottohub/models/video/reply/item.dart';

class CommentListResult {
  final List<ReplyItemModel> replies;
  final bool hasMore;

  CommentListResult({required this.replies, required this.hasMore});
}

abstract class ICommentRepository {
  Future<CommentListResult> getVideoComments({required String videoId, String? parentId, int offset = 0, int num = 12});
  Future<Map<String, dynamic>> commentVideo({required String videoId, String? parentId, required String content});
  Future<Map<String, dynamic>> deleteVideoComment({required String videoId, required String commentId});
  Future<Map<String, dynamic>> likeComment({required String commentId});
}
