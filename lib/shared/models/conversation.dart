import 'package:equatable/equatable.dart';

import 'message.dart';
import 'user_profile.dart';

enum ConversationType { direct, group }

/// Unified inbox item — 1:1 chat or Telegram-style group.
class ChatConversation extends Equatable {
  const ChatConversation({
    required this.id,
    this.type = ConversationType.direct,
    this.peer,
    this.title,
    this.description = '',
    this.avatarUrl,
    this.members = const [],
    this.adminIds = const [],
    this.lastMessage,
    this.unreadCount = 0,
    this.updatedAt,
    this.isTyping = false,
    this.languageCodes = const [],
    this.flagCountryCode,
  });

  final String id;
  final ConversationType type;
  final UserProfile? peer;
  final String? title;
  final String description;
  final String? avatarUrl;
  final List<UserProfile> members;
  final List<String> adminIds;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime? updatedAt;
  final bool isTyping;

  /// ISO-ish language codes for discover filters: es, de, fr, ja, pt, en…
  final List<String> languageCodes;

  /// Country code for circular flag (ES, DE, FR…).
  final String? flagCountryCode;

  bool get isGroup => type == ConversationType.group;

  String get displayTitle {
    if (isGroup) return title ?? 'Group';
    return peer?.displayName ?? 'Chat';
  }

  String get subtitlePreview {
    if (isGroup) return '${members.length} members';
    return peer?.status.name ?? '';
  }

  int get memberCount => isGroup ? members.length : 2;

  ChatConversation copyWith({
    String? title,
    String? description,
    String? avatarUrl,
    List<UserProfile>? members,
    List<String>? adminIds,
    ChatMessage? lastMessage,
    int? unreadCount,
    bool? isTyping,
    DateTime? updatedAt,
    List<String>? languageCodes,
    String? flagCountryCode,
  }) {
    return ChatConversation(
      id: id,
      type: type,
      peer: peer,
      title: title ?? this.title,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      members: members ?? this.members,
      adminIds: adminIds ?? this.adminIds,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isTyping: isTyping ?? this.isTyping,
      languageCodes: languageCodes ?? this.languageCodes,
      flagCountryCode: flagCountryCode ?? this.flagCountryCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        unreadCount,
        isTyping,
        lastMessage,
        members.length,
        languageCodes,
        flagCountryCode,
      ];
}
