import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart'
    show ZerexaConversation, ZerexaDirectMessage;
import 'package:piliotto/repositories/i_message_repository.dart';
import 'package:piliotto/utils/storage.dart';
import 'controller.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late MessageController controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MessageController());

    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = view.physicalSize.width / view.devicePixelRatio;
    final isWideScreen = screenWidth >= 800;

    if (!isWideScreen) {
      final parameters = Get.parameters;
      final mid = parameters['mid'];
      final name = parameters['name'];
      final face = parameters['face'];

      if (mid != null && name != null && !_hasNavigated) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed('/whisperDetail', parameters: {
            'mid': mid,
            'name': name,
            'face': face ?? '',
            'heroTag': mid,
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        centerTitle: true,
      ),
      body: isWideScreen ? _buildWideLayout(theme) : _buildNarrowLayout(theme),
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      children: [
        SizedBox(width: 320, child: _buildFriendListPanel(theme)),
        Container(width: 1, color: theme.colorScheme.outlineVariant.withAlpha(50)),
        Expanded(
          child: Obx(() {
            final conv = controller.selectedFriend.value;
            if (conv == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: 16),
                    Text('选择一个对话开始聊天', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              );
            }
            return _ChatDetailPanel(
              key: ValueKey(conv.otherUser.id),
              friendUserId: conv.otherUser.id,
              friendName: conv.otherUser.username,
              friendAvatar: conv.otherUser.gravatarUrl,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) => _buildFriendListPanel(theme);

  Widget _buildFriendListPanel(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value && controller.friendList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty && controller.friendList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => controller.loadFriendList(refresh: true), child: const Text('重试')),
            ],
          ),
        );
      }
      if (controller.friendList.isEmpty) {
        return const Center(child: Text('暂无消息'));
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadFriendList(refresh: true),
        child: ListView.builder(
          itemCount: controller.friendList.length,
          itemBuilder: (context, index) => _buildFriendItem(controller.friendList[index], theme),
        ),
      );
    });
  }

  Widget _buildFriendItem(ZerexaConversation conv, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;
    return Obx(() {
      final isSelected = controller.selectedFriend.value?.otherUser.id == conv.otherUser.id;
      return Container(
        color: isSelected ? theme.colorScheme.primaryContainer.withAlpha(100) : null,
        child: ListTile(
          onTap: () {
            if (isWideScreen) {
              controller.selectFriend(conv);
            } else {
              Get.toNamed('/whisperDetail', parameters: {
                'mid': conv.otherUser.id,
                'name': conv.otherUser.username,
                'face': conv.otherUser.gravatarUrl ?? '',
                'heroTag': conv.otherUser.id,
              });
            }
          },
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: conv.otherUser.gravatarUrl != null && conv.otherUser.gravatarUrl!.isNotEmpty
                ? NetworkImage(conv.otherUser.gravatarUrl!)
                : null,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: conv.otherUser.gravatarUrl == null || conv.otherUser.gravatarUrl!.isEmpty
                ? Icon(Icons.person, size: 24, color: theme.colorScheme.onPrimaryContainer)
                : null,
          ),
          title: Text(conv.otherUser.username, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: conv.lastMessage.isNotEmpty
              ? Text(conv.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
              : null,
          trailing: conv.unreadCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    conv.unreadCount > 99 ? '99+' : conv.unreadCount.toString(),
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onError),
                  ),
                )
              : null,
        ),
      );
    });
  }
}

class _ChatDetailPanel extends StatefulWidget {
  final String friendUserId;
  final String friendName;
  final String? friendAvatar;

  const _ChatDetailPanel({
    super.key,
    required this.friendUserId,
    required this.friendName,
    this.friendAvatar,
  });

  @override
  State<_ChatDetailPanel> createState() => _ChatDetailPanelState();
}

class _ChatDetailPanelState extends State<_ChatDetailPanel> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  RxList<ZerexaDirectMessage> messages = <ZerexaDirectMessage>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSending = false.obs;
  RxString errorMessage = ''.obs;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    loadMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => loadMessages());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    scrollController.dispose();
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future loadMessages({bool refresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await Get.find<IMessageRepository>().getDirectMessages(widget.friendUserId);
      final list = data['messages'] as List? ?? [];
      final msgs = list.map((e) => ZerexaDirectMessage.fromJson(e as Map<String, dynamic>)).toList();
      messages.assignAll(msgs);
      await Get.find<IMessageRepository>().markDirectRead(widget.friendUserId);
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
      await Get.find<IMessageRepository>().sendDirectMessage(widget.friendUserId, text);
      messageController.clear();
      await loadMessages(refresh: true);
    } catch (e) {
      // silent
    } finally {
      isSending.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userInfo = GStrorage.userInfo.get('userInfoCache');
    final myId = userInfo?.mid?.toString() ?? '';
    final myAvatar = userInfo?.face;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(50))),
          ),
          child: Row(
            children: [
              if (widget.friendAvatar != null && widget.friendAvatar!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.friendAvatar!)),
                ),
              Text(widget.friendName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (isLoading.value && messages.isEmpty) return const Center(child: CircularProgressIndicator());
            if (errorMessage.value.isNotEmpty && messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage.value),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => loadMessages(refresh: true), child: const Text('重试')),
                  ],
                ),
              );
            }
            if (messages.isEmpty) return const Center(child: Text('暂无消息'));
            return RefreshIndicator(
              onRefresh: () => loadMessages(refresh: true),
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == myId;
                  return _buildMessageItem(msg, isMe, theme, myAvatar);
                },
              ),
            );
          }),
        ),
        _buildInputArea(theme),
      ],
    );
  }

  Widget _buildMessageItem(ZerexaDirectMessage msg, bool isMe, ThemeData theme, String? myAvatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.friendAvatar != null && widget.friendAvatar!.isNotEmpty
                  ? NetworkImage(widget.friendAvatar!)
                  : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: widget.friendAvatar == null || widget.friendAvatar!.isEmpty
                  ? Icon(Icons.person, size: 16, color: theme.colorScheme.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                  child: Text(msg.content, style: TextStyle(fontSize: 15, color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: isMe ? const EdgeInsets.only(right: 8) : const EdgeInsets.only(left: 40),
                  child: Text(msg.createdAt, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: myAvatar != null && myAvatar.isNotEmpty ? NetworkImage(myAvatar) : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: myAvatar == null || myAvatar.isEmpty
                  ? Icon(Icons.person, size: 16, color: theme.colorScheme.onPrimaryContainer)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton.filled(
                onPressed: isSending.value ? null : sendMessage,
                icon: isSending.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
              )),
        ],
      ),
    );
  }
}
