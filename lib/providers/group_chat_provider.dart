import 'package:flutter/rendering.dart';
import 'package:flutter_co_activity_connect/model/message.dart';
import 'package:flutter_co_activity_connect/providers/socket_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GroupChatNotifer extends StateNotifier<AsyncValue<List<Message>>> {
  final IO.Socket socket;
  final int activityId;
  final String userId;

  GroupChatNotifer({
    required this.socket,
    required this.activityId,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadMessages();
    _setupListeners();
    _joinRoom();
  }

  Future<void> _loadMessages() async {
    try {
      final url = Uri.parse(
        'https://backend.pasitlab.com/api/activities/$activityId/messages',
      );
      final response = await http.get(url);
      debugPrint("Response load message: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
        state = AsyncValue.data(messages);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      debugPrint("Error load message: $e, $stack");
    }
  }

  void _setupListeners() {
    socket.on('message:group:received', (data) {
      final message = Message.fromJson(data);
      state.whenData((messages) {
        state = AsyncValue.data([...messages, message]);
      });
    });

    socket.on("message:group:edited", (data) {
      final editMessage = Message.fromJson(data);
      state.whenData((messages) {
        final updateMessage = messages.map((msg) {
          return msg.messageId == editMessage.messageId ? editMessage : msg;
        }).toList();
        state = AsyncValue.data(updateMessage);
      });
    });
  }

  void _joinRoom() {
    socket.emit('join:activity', activityId);
  }

  void sendMessage(String message) {
    debugPrint("Message: $message");
    socket.emit('message:group', {
      'activityId': activityId,
      'senderId': userId,
      'message': message,
    });
  }

  void editMessage(int messageId, String newMessage) {
    socket.emit('message:edit', {
      'messageId': messageId,
      'messageType': 'group',
      'newMessage': newMessage,
      'userId': userId,
    });
  }

  void startTyping() {
    socket.emit('typing:start', {
      'type': 'activity',
      'id': activityId,
      'userId': userId,
    });
  }

  void stopTyping() {
    socket.emit('typing:stop', {
      'type': 'activity',
      'id': activityId,
      'userId': userId,
    });
  }

  @override
  void dispose() {
    socket.emit('leave:activity', activityId);
    super.dispose();
  }
}

final groupChatProvider =
    StateNotifierProvider.family<
      GroupChatNotifer,
      AsyncValue<List<Message>>,
      ({int activityId, String userId})
    >((ref, params) {
      final socket = ref.watch(socketProvider);

      return GroupChatNotifer(
        socket: socket,
        activityId: params.activityId,
        userId: params.userId,
      );
    });
