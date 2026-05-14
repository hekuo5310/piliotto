import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/repositories/i_message_repository.dart';

class MessageListController extends GetxController {
  final IMessageRepository _messageRepo = Get.find<IMessageRepository>();
  RxList<ZerexaConversation> friendList = <ZerexaConversation>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFriendList();
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

  Future onRefresh() async => loadFriendList(refresh: true);
}
