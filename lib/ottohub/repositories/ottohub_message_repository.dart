import '../api/services/message_service.dart';
import '../api/models/message.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_message_repository.dart';

class OttohubMessageRepository extends BaseRepository implements IMessageRepository {
  @override
  Future<MessageSummary> getSummary() => MessageService.getSummary();

  @override
  Future<List<ZerexaInboxMessage>> getInbox() => MessageService.getInbox();

  @override
  Future<void> markInboxRead({String? id}) => MessageService.markInboxRead(id: id);

  @override
  Future<List<ZerexaConversation>> getConversations() {
    return withCache(
      'getConversations',
      () => MessageService.getConversations(),
      cacheConfig: const CacheConfig(duration: Duration(minutes: 1)),
    );
  }

  @override
  Future<Map<String, dynamic>> getDirectMessages(String userId) =>
      MessageService.getDirectMessages(userId);

  @override
  Future<void> sendDirectMessage(String userId, String content) {
    invalidateCache('getConversations');
    return MessageService.sendDirectMessage(userId, content);
  }

  @override
  Future<void> markDirectRead(String userId) => MessageService.markDirectRead(userId);

  @override
  Future<int> getUnreadMessageNum() => MessageService.getUnreadMessageNum();
}
