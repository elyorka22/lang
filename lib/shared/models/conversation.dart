import 'package:equatable/equatable.dart';

import 'message.dart';
import 'user_profile.dart';

class ChatConversation extends Equatable {
  const ChatConversation({
    required this.id,
    required this.peer,
    this.lastMessage,
    this.unreadCount = 0,
    this.updatedAt,
    this.isTyping = false,
  });

  final String id;
  final UserProfile peer;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime? updatedAt;
  final bool isTyping;

  ChatConversation copyWith({
    ChatMessage? lastMessage,
    int? unreadCount,
    bool? isTyping,
    DateTime? updatedAt,
  }) {
    return ChatConversation(
      id: id,
      peer: peer,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [id, unreadCount, isTyping, lastMessage];
}
