import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/data/mock_data.dart';
import '../../../shared/models/conversation.dart';
import '../../../shared/models/message.dart';
import '../../../shared/models/user_profile.dart';

final conversationsProvider =
    StateNotifierProvider<ConversationsController, List<ChatConversation>>(
        (ref) {
  return ConversationsController()..load();
});

class ConversationsController extends StateNotifier<List<ChatConversation>> {
  ConversationsController() : super(const []);

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = MockData.conversations();
  }
}

class ChatRoomState {
  const ChatRoomState({
    required this.conversationId,
    required this.peer,
    this.messages = const [],
    this.isTyping = false,
    this.isLoading = false,
  });

  final String conversationId;
  final UserProfile peer;
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isLoading;

  ChatRoomState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isLoading,
  }) {
    return ChatRoomState(
      conversationId: conversationId,
      peer: peer,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final chatRoomProvider = StateNotifierProvider.family<ChatRoomController,
    ChatRoomState, String>((ref, conversationId) {
  return ChatRoomController(conversationId)..load();
});

class ChatRoomController extends StateNotifier<ChatRoomState> {
  ChatRoomController(String conversationId)
      : super(
          ChatRoomState(
            conversationId: conversationId,
            peer: MockData.users.first,
            isLoading: true,
          ),
        );

  final _uuid = const Uuid();

  Future<void> load() async {
    final conv = MockData.conversations().cast<ChatConversation?>().firstWhere(
          (c) => c?.id == state.conversationId,
          orElse: () => null,
        );
    final peer = conv?.peer ??
        MockData.users.firstWhere(
          (u) => state.conversationId.contains(u.id),
          orElse: () => MockData.users.first,
        );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = ChatRoomState(
      conversationId: state.conversationId,
      peer: peer,
      messages: MockData.messagesFor(state.conversationId),
      isLoading: false,
    );
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    final msg = ChatMessage(
      id: _uuid.v4(),
      conversationId: state.conversationId,
      senderId: 'me',
      type: MessageType.text,
      text: text.trim(),
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );
    state = state.copyWith(messages: [...state.messages, msg]);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final updated = state.messages
        .map((m) =>
            m.id == msg.id ? m.copyWith(status: MessageStatus.delivered) : m)
        .toList();
    state = state.copyWith(messages: updated);

    // Simulate peer typing + reply for demo polish
    state = state.copyWith(isTyping: true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final reply = ChatMessage(
      id: _uuid.v4(),
      conversationId: state.conversationId,
      senderId: state.peer.id,
      type: MessageType.text,
      text: 'Nice! Keep practicing 💬',
      createdAt: DateTime.now(),
      status: MessageStatus.delivered,
    );
    state = state.copyWith(
      isTyping: false,
      messages: [...state.messages, reply],
    );
  }

  void markTranslated(String messageId, String translation) {
    state = state.copyWith(
      messages: state.messages
          .map((m) =>
              m.id == messageId ? m.copyWith(translatedText: translation) : m)
          .toList(),
    );
  }
}
