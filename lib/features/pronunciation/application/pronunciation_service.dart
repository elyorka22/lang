import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps [SpeechToText] for lesson pronunciation checks (no paid APIs).
class PronunciationService {
  PronunciationService({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _initialized = false;

  bool get isAvailable => _speech.isAvailable;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_initialized) return _speech.isAvailable;

    _initialized = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      debugLogging: false,
    );
    return _initialized && _speech.isAvailable;
  }

  void Function(String status)? onStatusChanged;
  void Function(String message)? onError;
  void Function(String text, {required bool isFinal})? onTextChanged;

  void _onStatus(String status) {
    onStatusChanged?.call(status);
  }

  void _onError(SpeechRecognitionError error) {
    onError?.call(error.errorMsg);
  }

  /// Starts listening; stops after [pauseFor] silence or [listenFor] max time.
  Future<bool> startListening({
    String? localeId,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return false;
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    final resolvedLocale = await _resolveLocale(localeId);

    return _speech.listen(
      onResult: _handleResult,
      localeId: resolvedLocale,
      listenFor: listenFor,
      pauseFor: pauseFor,
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<String?> _resolveLocale(String? languageCode) async {
    if (languageCode == null || languageCode.isEmpty) return null;
    final locales = await _speech.locales();
    for (final locale in locales) {
      if (locale.localeId.startsWith(languageCode)) {
        return locale.localeId;
      }
    }
    return null;
  }

  void _handleResult(SpeechRecognitionResult result) {
    onTextChanged?.call(
      result.recognizedWords,
      isFinal: result.finalResult,
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }

  Future<List<LocaleName>> locales() => _speech.locales();

  void dispose() {
    onStatusChanged = null;
    onError = null;
    onTextChanged = null;
  }
}
