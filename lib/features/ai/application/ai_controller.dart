import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/learning_stats.dart';

class AiMessage {
  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String role; // user | assistant
  final String content;
  final DateTime createdAt;
}

class AiState {
  const AiState({
    this.messages = const [],
    this.isStreaming = false,
    this.remainingFree = 10,
    this.mode = 'tutor',
  });

  final List<AiMessage> messages;
  final bool isStreaming;
  final int remainingFree;
  final String mode;

  AiState copyWith({
    List<AiMessage>? messages,
    bool? isStreaming,
    int? remainingFree,
    String? mode,
  }) {
    return AiState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      remainingFree: remainingFree ?? this.remainingFree,
      mode: mode ?? this.mode,
    );
  }
}

final aiControllerProvider =
    StateNotifierProvider<AiController, AiState>((ref) {
  return AiController();
});

class AiController extends StateNotifier<AiState> {
  AiController()
      : super(
          AiState(
            messages: [
              AiMessage(
                id: 'welcome',
                role: 'assistant',
                content:
                    'Hi! I am your Lingua AI tutor. Ask me to explain grammar, correct sentences, roleplay, or prepare for IELTS/TOEFL.',
                createdAt: DateTime.now(),
              ),
            ],
          ),
        );

  final _uuid = const Uuid();

  void setMode(String mode) {
    state = state.copyWith(mode: mode);
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.isStreaming) return;
    if (state.remainingFree <= 0) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          AiMessage(
            id: _uuid.v4(),
            role: 'assistant',
            content:
                'You have reached the free AI limit for today. Upgrade to Premium for unlimited tutoring.',
            createdAt: DateTime.now(),
          ),
        ],
      );
      return;
    }

    final userMsg = AiMessage(
      id: _uuid.v4(),
      role: 'user',
      content: text.trim(),
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isStreaming: true,
      remainingFree: state.remainingFree - 1,
    );

    await Future<void>.delayed(const Duration(milliseconds: 700));
    final reply = _mockReply(text, state.mode);
    state = state.copyWith(
      isStreaming: false,
      messages: [
        ...state.messages,
        AiMessage(
          id: _uuid.v4(),
          role: 'assistant',
          content: reply,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  String _mockReply(String input, String mode) {
    switch (mode) {
      case 'grammar':
        return 'Grammar tip: Check subject–verb agreement and article usage in “$input”. A polished version could be: “${input.trim().capitalizeFix()}”.';
      case 'roleplay':
        return 'Roleplay (café):\nWaiter: ¡Bienvenido! ¿Qué desea pedir?\nYou can reply with a drink and a tapa. Try: “Quisiera un café con leche, por favor.”';
      case 'ielts':
        return 'IELTS Speaking Part 1 practice:\nDescribe a place you like to study. Aim for 40–60 seconds. Focus on fluency and coherence.';
      default:
        return 'Great question! Here is a clear explanation and a short exercise related to “$input”.\n\n1) Meaning in context\n2) Example sentence\n3) Mini drill: rewrite the sentence in past tense.\n\n(Connected to NestJS /ai/chat in production.)';
    }
  }

  Future<VoiceAnalysisResult> analyzeVoice() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return const VoiceAnalysisResult(
      pronunciationScore: 86,
      fluency: 81,
      accent: 'Mild non-native',
      speakingSpeed: 132,
      naturalness: 78,
      mispronouncedWords: ['gustaría', 'próximo'],
      suggestions: [
        'Lengthen the stressed syllable in “gustaría”.',
        'Soften the “x” in “próximo” toward /ks/.',
        'Pause briefly between clauses for fluency.',
      ],
    );
  }
}

extension on String {
  String capitalizeFix() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
