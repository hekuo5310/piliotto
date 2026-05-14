import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/repositories/i_message_repository.dart';
import 'package:piliotto/utils/storage.dart';

class MessageController extends GetxController {
  final IMessageRepository _messageRepo = Get.find<IMessageRepository>();
  RxList<ZerexaConversation> friendList = <ZerexaConversation>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Rxn<ZerexaConversation> selectedFriend = Rxn<ZerexaConversation>();

  @override
  void onInit() {
    super.onInit();
    _checkInitialFriend();
    loadFriendList();
  }

  void _checkInitialFriend() {
    final parameters = Get.parameters;
    final userId = parameters['mid'];
    final name = parameters['name'];
    final face = parameters['face'];

    if (userId != null && name != null) {
      selectedFriend.value = ZerexaConversation(
        otherUser: ZerexaOtherUser(id: userId, uid: int.tryParse(userId) ?? 0, username: name, gravatarUrl: face),
        lastMessage: '',
        lastMessageAt: '',
        unreadCount: 0,
      );
    }
  }

  Future loadFriendList({bool refresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final convs = await _messageRepo.getConversations();
      friendList.assignAll(convs);
    } catch (e) {
      errorMessage.value = '加载失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectFriend(ZerexaConversation conv) {
    selectedFriend.value = conv;
  }

  void clearSelection() {
    selectedFriend.value = null;
  }
}
