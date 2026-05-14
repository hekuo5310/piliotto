class ZerexaOtherUser {
  final String id;
  final int uid;
  final String username;
  final String? gravatarUrl;

  ZerexaOtherUser({required this.id, required this.uid, required this.username, this.gravatarUrl});

  factory ZerexaOtherUser.fromJson(Map<String, dynamic> json) => ZerexaOtherUser(
        id: json['id']?.toString() ?? '',
        uid: json['uid'] is int ? json['uid'] : int.tryParse(json['uid']?.toString() ?? '0') ?? 0,
        username: json['username']?.toString() ?? '',
        gravatarUrl: json['gravatar_url']?.toString(),
      );
}

class ZerexaDirectMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final int isRead;
  final String createdAt;

  ZerexaDirectMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ZerexaDirectMessage.fromJson(Map<String, dynamic> json) => ZerexaDirectMessage(
        id: json['id']?.toString() ?? '',
        senderId: json['sender_id']?.toString() ?? '',
        recipientId: json['recipient_id']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        isRead: json['is_read'] is int ? json['is_read'] : 0,
        createdAt: json['created_at']?.toString() ?? '',
      );
}

class ZerexaConversation {
  final ZerexaOtherUser otherUser;
  final String lastMessage;
  final String lastMessageAt;
  final int unreadCount;

  ZerexaConversation({
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ZerexaConversation.fromJson(Map<String, dynamic> json) => ZerexaConversation(
        otherUser: ZerexaOtherUser.fromJson(json['other_user'] as Map<String, dynamic>),
        lastMessage: json['last_message']?.toString() ?? '',
        lastMessageAt: json['last_message_at']?.toString() ?? '',
        unreadCount: json['unread_count'] is int ? json['unread_count'] : 0,
      );
}

class ZerexaInboxMessage {
  final String id;
  final String type;
  final String title;
  final String content;
  final String? relatedUserId;
  final String? relatedVideoId;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? relatedUser;

  ZerexaInboxMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.relatedUserId,
    this.relatedVideoId,
    required this.isRead,
    required this.createdAt,
    this.relatedUser,
  });

  factory ZerexaInboxMessage.fromJson(Map<String, dynamic> json) => ZerexaInboxMessage(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        relatedUserId: json['related_user_id']?.toString(),
        relatedVideoId: json['related_video_id']?.toString(),
        isRead: json['is_read'] == true || json['is_read'] == 1,
        createdAt: json['created_at']?.toString() ?? '',
        relatedUser: json['related_user'] as Map<String, dynamic>?,
      );
}

class MessageSummary {
  final int inboxUnread;
  final int dmUnread;
  final int totalUnread;

  MessageSummary({required this.inboxUnread, required this.dmUnread, required this.totalUnread});

  factory MessageSummary.fromJson(Map<String, dynamic> json) => MessageSummary(
        inboxUnread: json['inboxUnread'] is int ? json['inboxUnread'] : 0,
        dmUnread: json['dmUnread'] is int ? json['dmUnread'] : 0,
        totalUnread: json['totalUnread'] is int ? json['totalUnread'] : 0,
      );
}
