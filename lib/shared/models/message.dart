import 'package:equatable/equatable.dart';

enum MessageType { text, voice, image, system, sticker }

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.createdAt,
    this.text,
    this.mediaUrl,
    this.voiceDurationSec,
    this.replyToId,
    this.status = MessageStatus.sent,
    this.isEdited = false,
    this.translatedText,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final int? voiceDurationSec;
  final String? replyToId;
  final MessageStatus status;
  final bool isEdited;
  final String? translatedText;
  final DateTime createdAt;

  bool get isMine => false; // resolved in UI via current user id

  ChatMessage copyWith({
    MessageStatus? status,
    String? text,
    bool? isEdited,
    String? translatedText,
    bool clearTranslated = false,
  }) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      text: text ?? this.text,
      mediaUrl: mediaUrl,
      voiceDurationSec: voiceDurationSec,
      replyToId: replyToId,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      translatedText:
          clearTranslated ? null : (translatedText ?? this.translatedText),
      createdAt: createdAt,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      text: json['text'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      voiceDurationSec: json['voiceDurationSec'] as int?,
      replyToId: json['replyToId'] as String?,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      isEdited: json['isEdited'] as bool? ?? false,
      translatedText: json['translatedText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'type': type.name,
        'text': text,
        'mediaUrl': mediaUrl,
        'voiceDurationSec': voiceDurationSec,
        'replyToId': replyToId,
        'status': status.name,
        'isEdited': isEdited,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, text, status, isEdited, translatedText];
}
