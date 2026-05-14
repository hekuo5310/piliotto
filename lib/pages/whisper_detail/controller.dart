import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/repositories/i_message_repository.dart';

class WhisperDetailController extends GetxController {
  final IMessageRepository _messageRepo = Get.find<IMessageRepository>();
  final String friendUserId;
  final String friendName;
  final String? friendAvatar;
  final String heroTag;

  WhisperDetailController({
    required this.friendUserId,
    required this.friendName,
    this.friendAvatar,
    required this.heroTag,
  });

  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  RxList<ZerexaDirectMessage> messages = <ZerexaDirectMessage>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSending = false.obs;
  RxString errorMessage = ''.obs;
  RxString snackbarMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future loadMessages({bool refresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _messageRepo.getDirectMessages(friendUserId);
      final list = data['messages'] as List? ?? [];
      final msgs = list.map((e) => ZerexaDirectMessage.fromJson(e as Map<String, dynamic>)).toList();
      messages.assignAll(msgs);
      await _messageRepo.markDirectRead(friendUserId);
    } catch (e) {
      errorMessage.value = '加载失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending.value) return;
    isSending.value = true;
    try {
      await _messageRepo.sendDirectMessage(friendUserId, text);
      messageController.clear();
      await loadMessages(refresh: true);
    } catch (e) {
      snackbarMessage.value = '消息发送失败: $e';
    } finally {
      isSending.value = false;
    }
  }
}
