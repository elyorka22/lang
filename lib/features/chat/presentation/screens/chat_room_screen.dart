import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/message.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../memorizer/presentation/widgets/save_to_memorizer_sheet.dart';
import '../../../social/application/social_controller.dart';
import '../../application/chat_controller.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text;
    _input.clear();
    ref.read(chatRoomProvider(widget.conversationId).notifier).sendText(text);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(chatRoomProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            if (room.isGroup) {
              context.push('/groups/${room.conversationId}');
            } else if (room.peer != null) {
              context.push('/users/${room.peer!.id}');
            }
          },
          child: Row(
            children: [
              if (room.isGroup)
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.brandGradientSoft,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    room.title.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                AppAvatar(
                  name: room.peer?.displayName ?? '?',
                  url: room.peer?.avatarUrl,
                  size: 40,
                  status: room.peer?.status,
                  showStatus: true,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.title, style: context.textTheme.titleSmall),
                    Text(
                      room.isTyping
                          ? 'typing…'
                          : room.isGroup
                              ? '${room.memberCount} members'
                              : (room.peer?.status.name ?? ''),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: room.isTyping
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (room.isGroup)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => context.push('/groups/${room.conversationId}'),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () => context.showSnack('Video call — connect WebRTC'),
            ),
            IconButton(
              icon: const Icon(Icons.call_outlined),
              onPressed: () => context.showSnack('Voice call — connect WebRTC'),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: room.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: room.messages.length,
                    itemBuilder: (_, i) {
                      final m = room.messages[i];
                      final mine = m.senderId == 'me';
                      final isSystem = m.type == MessageType.system ||
                          m.senderId == 'system';
                      if (isSystem) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              m.text ?? '',
                              style: context.textTheme.labelSmall,
                            ),
                          ),
                        );
                      }
                      return _MessageBubble(
                        message: m,
                        isMine: mine,
                        showSender: room.isGroup && !mine,
                        senderName: room.senderName(m.senderId),
                        onLongPress: () => _showActions(m, mine),
                        onSaveSelection: (selected) {
                          showSaveToMemorizerSheet(
                            context: context,
                            ref: ref,
                            text: selected,
                            conversationId: widget.conversationId,
                            messageId: m.id,
                            contextSentence: m.text ?? '',
                          );
                        },
                      );
                    },
                  ),
          ),
          _Composer(
            controller: _input,
            onSend: _send,
            onAttach: () => context.showSnack('Image upload via R2/Spaces'),
            onVoice: () =>
                context.showSnack('Hold to record voice (record package)'),
          ),
        ],
      ),
    );
  }

  void _showActions(ChatMessage message, bool isMine) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Translate'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(chatRoomProvider(widget.conversationId).notifier)
                      .markTranslated(
                        message.id,
                        'How are you today? (demo translation)',
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.spellcheck),
                title: const Text('Grammar check'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.showSnack('AI grammar check ready for NestJS /ai/grammar');
                },
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: const Text('Explain'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.showSnack('AI explain endpoint: /ai/explain');
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Improve sentence'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.showSnack('AI improve endpoint: /ai/improve');
                },
              ),
              if (!isMine && message.senderId != 'system')
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('Thanks for correction (+karma)'),
                  subtitle: Text('+$karmaPerThanks XP to helper'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(socialControllerProvider.notifier)
                        .awardCorrectionKarma(helperUserId: message.senderId);
                    context.showSnack(
                      'Karma sent · helpers unlock Mentor at $mentorKarmaThreshold',
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: const Text('Save to Запоминалка'),
                onTap: () {
                  Navigator.pop(ctx);
                  showSaveToMemorizerSheet(
                    context: context,
                    ref: ref,
                    text: message.text ?? '',
                    conversationId: widget.conversationId,
                    messageId: message.id,
                    contextSentence: message.text ?? '',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Save vocabulary'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.showSnack('Saved to vocabulary');
                },
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over_outlined),
                title: const Text('Pronounce'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.showSnack('TTS pronunciation');
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.text ?? ''));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share'),
                onTap: () => Navigator.pop(ctx),
              ),
              if (isMine)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: ctx.colors.error),
                title: Text('Delete', style: TextStyle(color: ctx.colors.error)),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.onLongPress,
    required this.onSaveSelection,
    this.showSender = false,
    this.senderName = '',
  });

  final ChatMessage message;
  final bool isMine;
  final bool showSender;
  final String senderName;
  final VoidCallback onLongPress;
  final ValueChanged<String> onSaveSelection;

  @override
  Widget build(BuildContext context) {
    final bg = isMine
        ? AppColors.chatBubbleMine
        : (context.isDark
            ? AppColors.chatBubbleOtherDark
            : AppColors.chatBubbleOther);
    final fg = isMine ? Colors.white : context.colors.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 6),
              bottomRight: Radius.circular(isMine ? 6 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSender && senderName.isNotEmpty) ...[
                Text(
                  senderName,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              if (message.type == MessageType.voice)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_fill, color: fg, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '0:${(message.voiceDurationSec ?? 0).toString().padLeft(2, '0')}',
                      style: TextStyle(color: fg),
                    ),
                  ],
                )
              else
                SelectableText(
                  message.text ?? '',
                  style: TextStyle(color: fg, fontSize: 15, height: 1.35),
                  contextMenuBuilder: (context, editableTextState) {
                    final value = editableTextState.textEditingValue;
                    final selected =
                        value.selection.textInside(value.text).trim();
                    final items = <ContextMenuButtonItem>[
                      if (selected.isNotEmpty)
                        ContextMenuButtonItem(
                          label: 'Запоминалка',
                          onPressed: () {
                            ContextMenuController.removeAny();
                            onSaveSelection(selected);
                          },
                        ),
                      ...editableTextState.contextMenuButtonItems,
                    ];
                    return AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: editableTextState.contextMenuAnchors,
                      buttonItems: items,
                    );
                  },
                ),
              if (message.translatedText != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message.translatedText!,
                    style: TextStyle(
                      color: fg.withOpacity(0.9),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.createdAt.chatTime,
                    style: TextStyle(
                      color: fg.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.status == MessageStatus.read
                          ? Icons.done_all
                          : Icons.done,
                      size: 14,
                      color: message.status == MessageStatus.read
                          ? Colors.white
                          : fg.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.onVoice,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: context.isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onAttach,
              icon: const Icon(Icons.add_circle_outline),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Message',
                  filled: true,
                  fillColor: context.isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onVoice,
              icon: const Icon(Icons.mic_none_rounded),
            ),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
