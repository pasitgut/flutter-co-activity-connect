import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:flutter_co_activity_connect/model/message.dart';
import 'package:flutter_co_activity_connect/providers/group_chat_provider.dart';
import 'package:flutter_co_activity_connect/providers/socket_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_svg/svg.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final int activityId;
  final String currentUserId;
  final String activityName;

  const GroupChatScreen({
    super.key,
    required this.activityId,
    required this.currentUserId,
    required this.activityName,
  });

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socket = ref.read(socketProvider);

      socket.onConnect((_) {
        debugPrint('✅ Socket connected successfully!');
        socket.emit('register', widget.currentUserId);
      });

      socket.onConnectError((error) {
        debugPrint('❌ Connection Error: $error');
      });

      socket.onError((error) {
        debugPrint('❌ Socket Error: $error');
      });

      socket.onDisconnect((_) {
        debugPrint('🔌 Socket disconnected');
      });

      if (!socket.connected) {
        socket.connect();
      } else {
        socket.emit('register', widget.currentUserId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    ref
        .read(
          groupChatProvider((
            activityId: widget.activityId,
            userId: widget.currentUserId,
          )).notifier,
        )
        .sendMessage(message);

    _messageController.clear();
    _stopTyping();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _onTyping(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      ref
          .read(
            groupChatProvider((
              activityId: widget.activityId,
              userId: widget.currentUserId,
            )).notifier,
          )
          .startTyping();
    } else if (text.isEmpty && _isTyping) {
      _stopTyping();
    }
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      ref
          .read(
            groupChatProvider((
              activityId: widget.activityId,
              userId: widget.currentUserId,
            )).notifier,
          )
          .stopTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      groupChatProvider((
        activityId: widget.activityId,
        userId: widget.currentUserId,
      )),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Row(
            children: [
              CircleAvatar(child: Text("P")),
              const SizedBox(width: 10),
              Text(
                widget.activityName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (messages) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                    );
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == widget.currentUserId;
                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          showSenderName: !isMe,
                        );
                      },
                    );
                  },
                ),
              ),
              MessageInputField(
                controller: _messageController,
                onSend: _sendMessage,
                onChanged: _onTyping,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showSenderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSenderName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSenderName && message.sender != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.sender!.username,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (message.isEdited) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(edited)',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: isMe ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
                if (isMe && message.isRead) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 14, color: Colors.white70),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onChanged;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onChanged: onChanged,
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor,
              ),
              child: SvgPicture.asset(
                "images/send_fill.svg",
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
