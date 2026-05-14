import '../api/services/api_service.dart';
import '../models/video/reply/item.dart';
import '../models/video/reply/member.dart';
import '../models/video/reply/content.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';

class OttohubCommentRepository extends BaseRepository implements ICommentRepository {
  ReplyItemModel _fromZerexaComment(Map<String, dynamic> c, String videoId) {
    final member = ReplyMember(
      mid: c['author_id']?.toString() ?? '',
      uname: c['username']?.toString() ?? '',
      sign: '',
      avatar: c['gravatar_url']?.toString() ?? '',
      level: 1,
      pendant: Pendant(pid: 0, name: '', image: ''),
      officialVerify: {},
      vip: {'vipStatus': 0, 'vipType': 0},
      fansDetail: {},
    );
    final content = ReplyContent(
      message: c['content']?.toString() ?? '',
      atNameToMid: {},
      members: [],
      emote: {},
      jumpUrl: {},
      pictures: [],
      vote: {},
      richText: {},
      isText: true,
      topicsMeta: {},
    );
    final childReplies = (c['replies'] as List? ?? [])
        .map((r) => _fromZerexaComment(r as Map<String, dynamic>, videoId))
        .toList();
    final likeCount = c['like_count'] is int ? c['like_count'] as int : 0;
    return ReplyItemModel(
      rpid: 0,
      oid: 0,
      type: 1,
      mid: 0,
      root: 0,
      parent: 0,
      dialog: 0,
      count: childReplies.length,
      ctime: 0,
      like: likeCount,
      member: member,
      content: content,
      replies: childReplies,
      upAction: UpAction(like: false, reply: false),
      invisible: false,
      replyControl: ReplyControl(
        upReply: false,
        isUpTop: false,
        upLike: false,
        isShow: childReplies.isNotEmpty,
        entryText: childReplies.isNotEmpty ? '共${childReplies.length}条回复' : '',
        titleText: '',
        time: c['created_at']?.toString() ?? '',
        location: '',
      ),
      isUp: false,
      isTop: false,
      cardLabel: [],
    );
  }

  @override
  Future<CommentListResult> getVideoComments({
    required String videoId,
    String? parentId,
    int offset = 0,
    int num = 12,
  }) async {
    final data = await ApiService.request('/videos/$videoId/comments');
    final list = data as List;
    final replies = list.map((c) => _fromZerexaComment(c as Map<String, dynamic>, videoId)).toList();
    return CommentListResult(replies: replies, hasMore: replies.length >= num);
  }

  @override
  Future<Map<String, dynamic>> commentVideo({
    required String videoId,
    String? parentId,
    required String content,
  }) async {
    final data = await ApiService.request(
      '/videos/$videoId/comments',
      method: 'POST',
      requireToken: true,
      body: {'content': content, 'parent_id': parentId},
    );
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> deleteVideoComment({
    required String videoId,
    required String commentId,
  }) async {
    final data = await ApiService.request(
      '/videos/$videoId/comments/$commentId',
      method: 'DELETE',
      requireToken: true,
    );
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> likeComment({required String commentId}) async {
    final data = await ApiService.request(
      '/comments/$commentId/like',
      method: 'POST',
      requireToken: true,
    );
    return data as Map<String, dynamic>;
  }
}
