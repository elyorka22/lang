import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/data/mock_data.dart';
import '../../../shared/models/conversation.dart';
import '../../../shared/models/message.dart';
import '../../../shared/models/user_profile.dart';
import 'message_translator.dart';

final conversationsProvider =
    StateNotifierProvider<ConversationsController, List<ChatConversation>>(
        (ref) {
  return ConversationsController()..load();
});

class ConversationsController extends StateNotifier<List<ChatConversation>> {
  ConversationsController() : super(const []);

  final _uuid = const Uuid();

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final list = MockData.conversations();
    list.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    state = list;
  }

  ChatConversation? byId(String id) {
    for (final c in state) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Make a discoverable group available in the inbox / chat room.
  void ensureGroup(ChatConversation group) {
    if (!group.isGroup) return;
    if (byId(group.id) != null) return;
    final withMe = group.members.any((m) => m.id == 'me')
        ? group
        : group.copyWith(
            members: [MockData.currentUser, ...group.members],
          );
    state = [withMe, ...state];
  }

  /// Create a Telegram-style group and open it from the inbox.
  Future<ChatConversation> createGroup({
    required String title,
    required List<UserProfile> members,
    String description = '',
  }) async {
    final id = 'g_${_uuid.v4().substring(0, 8)}';
    final allMembers = <UserProfile>[
      MockData.currentUser,
      ...members.where((m) => m.id != 'me'),
    ];
    final group = ChatConversation(
      id: id,
      type: ConversationType.group,
      title: title.trim(),
      description: description.trim(),
      members: allMembers,
      adminIds: const ['me'],
      updatedAt: DateTime.now(),
      lastMessage: ChatMessage(
        id: _uuid.v4(),
        conversationId: id,
        senderId: 'system',
        type: MessageType.system,
        text: 'Group created',
        createdAt: DateTime.now(),
        status: MessageStatus.sent,
      ),
    );
    state = [group, ...state];
    return group;
  }

  void addMembers(String groupId, List<UserProfile> toAdd) {
    state = [
      for (final c in state)
        if (c.id == groupId && c.isGroup)
          c.copyWith(
            members: [
              ...c.members,
              ...toAdd.where(
                (u) => !c.members.any((m) => m.id == u.id),
              ),
            ],
            updatedAt: DateTime.now(),
          )
        else
          c,
    ];
  }

  void removeMember(String groupId, String userId) {
    state = [
      for (final c in state)
        if (c.id == groupId && c.isGroup)
          c.copyWith(
            members: c.members.where((m) => m.id != userId).toList(),
            adminIds: c.adminIds.where((id) => id != userId).toList(),
            updatedAt: DateTime.now(),
          )
        else
          c,
    ];
  }

  void leaveGroup(String groupId) {
    state = state.where((c) => c.id != groupId).toList();
  }

  void updateGroupInfo(
    String groupId, {
    String? title,
    String? description,
  }) {
    state = [
      for (final c in state)
        if (c.id == groupId && c.isGroup)
          c.copyWith(title: title, description: description)
        else
          c,
    ];
  }
}

class ChatRoomState {
  const ChatRoomState({
    required this.conversationId,
    required this.title,
    this.peer,
    this.isGroup = false,
    this.members = const [],
    this.memberCount = 0,
    this.messages = const [],
    this.isTyping = false,
    this.isLoading = false,
    this.translatingIds = const {},
  });

  final String conversationId;
  final String title;
  final UserProfile? peer;
  final bool isGroup;
  final List<UserProfile> members;
  final int memberCount;
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isLoading;
  final Set<String> translatingIds;

  ChatRoomState copyWith({
    String? title,
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isLoading,
    List<UserProfile>? members,
    int? memberCount,
    Set<String>? translatingIds,
  }) {
    return ChatRoomState(
      conversationId: conversationId,
      title: title ?? this.title,
      peer: peer,
      isGroup: isGroup,
      members: members ?? this.members,
      memberCount: memberCount ?? this.memberCount,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isLoading: isLoading ?? this.isLoading,
      translatingIds: translatingIds ?? this.translatingIds,
    );
  }

  String senderName(String senderId) {
    if (senderId == 'me') return 'You';
    if (senderId == 'system') return 'Lingua';
    for (final m in members) {
      if (m.id == senderId) return m.displayName;
    }
    if (peer?.id == senderId) return peer!.displayName;
    return 'Member';
  }

  UserProfile? senderProfile(String senderId) {
    if (senderId == 'me' || senderId == 'system') return null;
    for (final m in members) {
      if (m.id == senderId) return m;
    }
    if (peer?.id == senderId) return peer;
    return null;
  }
}

final chatRoomProvider = StateNotifierProvider.family<ChatRoomController,
    ChatRoomState, String>((ref, conversationId) {
  return ChatRoomController(ref, conversationId)..load();
});

class ChatRoomController extends StateNotifier<ChatRoomState> {
  ChatRoomController(this._ref, String conversationId)
      : super(
          ChatRoomState(
            conversationId: conversationId,
            title: 'Chat',
            isLoading: true,
          ),
        );

  final Ref _ref;
  final _uuid = const Uuid();

  Future<void> load() async {
    final conv =
        _ref.read(conversationsProvider.notifier).byId(state.conversationId) ??
            MockData.conversations().cast<ChatConversation?>().firstWhere(
                  (c) => c?.id == state.conversationId,
                  orElse: () => null,
                );

    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (conv == null) {
      state = ChatRoomState(
        conversationId: state.conversationId,
        title: 'Chat',
        peer: MockData.users.first,
        messages: MockData.messagesFor(state.conversationId),
        isLoading: false,
      );
      return;
    }

    state = ChatRoomState(
      conversationId: conv.id,
      title: conv.displayTitle,
      peer: conv.peer,
      isGroup: conv.isGroup,
      members: conv.isGroup
          ? conv.members
          : [
              if (conv.peer != null) conv.peer!,
              MockData.currentUser,
            ],
      memberCount: conv.memberCount,
      messages: MockData.messagesFor(conv.id),
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

    state = state.copyWith(isTyping: true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final replySender = state.isGroup
        ? (state.members.firstWhere(
            (m) => m.id != 'me',
            orElse: () => MockData.users.first,
          ).id)
        : (state.peer?.id ?? 'u1');
    final reply = ChatMessage(
      id: _uuid.v4(),
      conversationId: state.conversationId,
      senderId: replySender,
      type: MessageType.text,
      text: state.isGroup
          ? 'Nice point! Anyone else want to add something?'
          : 'Nice! Keep practicing 💬',
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

  Future<void> translateMessage(
    String messageId, {
    required String targetCode,
  }) async {
    ChatMessage? message;
    for (final m in state.messages) {
      if (m.id == messageId) message = m;
    }
    final text = message?.text?.trim() ?? '';
    if (text.isEmpty || state.translatingIds.contains(messageId)) return;

    state = state.copyWith(
      translatingIds: {...state.translatingIds, messageId},
    );

    try {
      final translation = await MessageTranslator.translate(
        text,
        targetCode: targetCode,
      );
      state = state.copyWith(
        translatingIds: {...state.translatingIds}..remove(messageId),
        messages: state.messages
            .map(
              (m) => m.id == messageId
                  ? m.copyWith(translatedText: translation)
                  : m,
            )
            .toList(),
      );
    } catch (_) {
      state = state.copyWith(
        translatingIds: {...state.translatingIds}..remove(messageId),
      );
    }
  }

  void clearTranslation(String messageId) {
    state = state.copyWith(
      messages: state.messages
          .map(
            (m) => m.id == messageId
                ? m.copyWith(clearTranslated: true)
                : m,
          )
          .toList(),
    );
  }
}
