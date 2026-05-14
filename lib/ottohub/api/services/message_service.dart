import '../services/api_service.dart';
import '../models/message.dart';

class MessageService {
  static Future<MessageSummary> getSummary() async {
    final data = await ApiService.request('/messages/summary', requireToken: true);
    return MessageSummary.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<ZerexaInboxMessage>> getInbox() async {
    final data = await ApiService.request('/messages/inbox', requireToken: true);
    return (data as List).map((e) => ZerexaInboxMessage.fromJson(e)).toList();
  }

  static Future<void> markInboxRead({String? id}) async {
    await ApiService.request('/messages/inbox/read',
        method: 'POST',
        requireToken: true,
        body: id != null ? {'id': id} : {});
  }

  static Future<List<ZerexaConversation>> getConversations() async {
    final data = await ApiService.request('/messages/conversations', requireToken: true);
    return (data as List).map((e) => ZerexaConversation.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> getDirectMessages(String userId) async {
    final data = await ApiService.request('/messages/direct/$userId', requireToken: true);
    return data as Map<String, dynamic>;
  }

  static Future<void> sendDirectMessage(String userId, String content) async {
    await ApiService.request('/messages/direct/$userId',
        method: 'POST', requireToken: true, body: {'content': content});
  }

  static Future<void> markDirectRead(String userId) async {
    await ApiService.request('/messages/direct/$userId/read',
        method: 'POST', requireToken: true);
  }

  static Future<Map<String, dynamic>> startDirectMessage({
    required String recipient,
    required String content,
  }) async {
    final data = await ApiService.request('/messages/direct/start',
        method: 'POST',
        requireToken: true,
        body: {'recipient': recipient, 'content': content});
    return data as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> searchUsers(String q) async {
    final data = await ApiService.request('/messages/users/search',
        requireToken: true, queryParams: {'q': q});
    return (data as List).cast<Map<String, dynamic>>();
  }

  static Future<int> getUnreadMessageNum() async {
    final summary = await getSummary();
    return summary.totalUnread;
  }
}
