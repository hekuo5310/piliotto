import 'package:piliotto/ottohub/api/models/message.dart';
import 'base_repository.dart';

abstract class IMessageRepository {
  Future<MessageSummary> getSummary();
  Future<List<ZerexaInboxMessage>> getInbox();
  Future<void> markInboxRead({String? id});
  Future<List<ZerexaConversation>> getConversations();
  Future<Map<String, dynamic>> getDirectMessages(String userId);
  Future<void> sendDirectMessage(String userId, String content);
  Future<void> markDirectRead(String userId);
  Future<int> getUnreadMessageNum();
}
