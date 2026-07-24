import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pronunciation_result.dart';
import 'pronunciation_comparator.dart';
import 'pronunciation_service.dart';

enum PronunciationStatus {
  idle,
  initializing,
  listening,
  processing,
  done,
  error,
}

class PronunciationState {
  const PronunciationState({
    this.status = PronunciationStatus.idle,
    this.expectedText = '',
    this.recognizedText = '',
    this.result,
    this.errorMessage,
    this.isSpeechAvailable = false,
  });

  final PronunciationStatus status;
  final String expectedText;
  final String recognizedText;
  final PronunciationResult? result;
  final String? errorMessage;
  final bool isSpeechAvailable;

  bool get isListening => status == PronunciationStatus.listening;
  bool get isBusy =>
      status == PronunciationStatus.initializing ||
      status == PronunciationStatus.listening ||
      status == PronunciationStatus.processing;

  PronunciationState copyWith({
    PronunciationStatus? status,
    String? expectedText,
    String? recognizedText,
    PronunciationResult? result,
    String? errorMessage,
    bool? isSpeechAvailable,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return PronunciationState(
      status: status ?? this.status,
      expectedText: expectedText ?? this.expectedText,
      recognizedText: recognizedText ?? this.recognizedText,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSpeechAvailable: isSpeechAvailable ?? this.isSpeechAvailable,
    );
  }
}

final pronunciationServiceProvider = Provider<PronunciationService>((ref) {
  final service = PronunciationService();
  ref.onDispose(service.dispose);
  return service;
});

final pronunciationComparatorProvider =
    Provider<PronunciationComparator>((ref) {
  return const PronunciationComparator();
});

final pronunciationControllerProvider =
    StateNotifierProvider<PronunciationController, PronunciationState>((ref) {
  return PronunciationController(
    ref.read(pronunciationServiceProvider),
    ref.read(pronunciationComparatorProvider),
  );
});

class PronunciationController extends StateNotifier<PronunciationState> {
  PronunciationController(this._service, this._comparator)
      : super(const PronunciationState()) {
    _bindService();
  }

  final PronunciationService _service;
  final PronunciationComparator _comparator;

  void _bindService() {
    _service.onTextChanged = (text, {required bool isFinal}) {
      if (!mounted) return;
      state = state.copyWith(recognizedText: text);
      if (isFinal && text.trim().isNotEmpty) {
        _finishWithText(text);
      }
    };

    _service.onStatusChanged = (status) {
      if (!mounted) return;
      if (status == 'notListening' &&
          state.status == PronunciationStatus.listening) {
        _finishWithText(state.recognizedText);
      }
    };

    _service.onError = (message) {
      if (!mounted) return;
      state = state.copyWith(
        status: PronunciationStatus.error,
        errorMessage: message,
      );
    };
  }

  void setExpectedText(String text) {
    state = state.copyWith(
      expectedText: text,
      recognizedText: '',
      clearResult: true,
      clearError: true,
      status: PronunciationStatus.idle,
    );
  }

  void reset() {
    state = state.copyWith(
      recognizedText: '',
      clearResult: true,
      clearError: true,
      status: PronunciationStatus.idle,
    );
  }

  Future<void> startListening({String? localeId}) async {
    if (state.expectedText.trim().isEmpty) {
      state = state.copyWith(
        status: PronunciationStatus.error,
        errorMessage: 'Nothing to practice yet.',
      );
      return;
    }

    state = state.copyWith(
      status: PronunciationStatus.initializing,
      recognizedText: '',
      clearResult: true,
      clearError: true,
    );

    final available = await _service.initialize();
    if (!mounted) return;

    if (!available) {
      state = state.copyWith(
        status: PronunciationStatus.error,
        errorMessage: 'Speech recognition is not available on this device.',
        isSpeechAvailable: false,
      );
      return;
    }

    final started = await _service.startListening(localeId: localeId);
    if (!mounted) return;

    if (!started) {
      state = state.copyWith(
        status: PronunciationStatus.error,
        errorMessage: 'Could not start listening. Check microphone permission.',
        isSpeechAvailable: available,
      );
      return;
    }

    state = state.copyWith(
      status: PronunciationStatus.listening,
      isSpeechAvailable: true,
    );
  }

  Future<void> stopListening() async {
    if (state.status != PronunciationStatus.listening) return;

    state = state.copyWith(status: PronunciationStatus.processing);
    await _service.stopListening();
    if (!mounted) return;
    _finishWithText(state.recognizedText);
  }

  void _finishWithText(String recognized) {
    if (state.status == PronunciationStatus.done ||
        state.status == PronunciationStatus.error) {
      return;
    }

    final trimmed = recognized.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        status: PronunciationStatus.error,
        errorMessage: 'No speech detected. Try again and speak clearly.',
      );
      return;
    }

    final result = _comparator.compare(
      expected: state.expectedText,
      recognized: trimmed,
    );

    state = state.copyWith(
      status: PronunciationStatus.done,
      recognizedText: trimmed,
      result: result,
    );
  }

  @override
  void dispose() {
    _service.stopListening();
    super.dispose();
  }
}
