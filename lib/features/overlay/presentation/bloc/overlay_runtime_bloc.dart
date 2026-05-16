import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tokam/core/services/ai_assistant_service.dart';

// ── States ──────────────────────────────────────────────────────────────────
enum OverlayViewStatus { idle, scanned, processing, speaking, error }

class OverlayRuntimeState {
  final OverlayViewStatus status;
  final String scrapedText;
  final String outputText;
  final String errorMessage;

  const OverlayRuntimeState({
    this.status = OverlayViewStatus.idle,
    this.scrapedText = '',
    this.outputText = '',
    this.errorMessage = '',
  });

  OverlayRuntimeState copyWith({
    OverlayViewStatus? status,
    String? scrapedText,
    String? outputText,
    String? errorMessage,
  }) =>
      OverlayRuntimeState(
        status: status ?? this.status,
        scrapedText: scrapedText ?? this.scrapedText,
        outputText: outputText ?? this.outputText,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Events ───────────────────────────────────────────────────────────────────
abstract class OverlayRuntimeEvent {}

/// Fired when bubble is tapped – reads SharedPrefs for latest screen text
class ScanCurrentScreen extends OverlayRuntimeEvent {}

/// User chose "Read Screen" action
class RequestReadScreen extends OverlayRuntimeEvent {}

/// User chose "Translate" action
class RequestTranslate extends OverlayRuntimeEvent {}

/// User chose "Summarize" action
class RequestSummarize extends OverlayRuntimeEvent {}

/// Stop TTS playback
class StopSpeaking extends OverlayRuntimeEvent {}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class OverlayRuntimeBloc extends Bloc<OverlayRuntimeEvent, OverlayRuntimeState> {
  final AiAssistantService _ai;

  OverlayRuntimeBloc({AiAssistantService? aiService})
      : _ai = aiService ?? AiAssistantService(),
        super(const OverlayRuntimeState()) {

    on<ScanCurrentScreen>(_onScan);
    on<RequestReadScreen>(_onRead);
    on<RequestTranslate>(_onTranslate);
    on<RequestSummarize>(_onSummarize);
    on<StopSpeaking>(_onStop);
  }

  Future<void> _onScan(ScanCurrentScreen event, Emitter<OverlayRuntimeState> emit) async {
    final text = await AiAssistantService.getScrapedScreenText();
    if (text.isEmpty) {
      emit(state.copyWith(
        status: OverlayViewStatus.error,
        errorMessage: 'No screen content found. Please open an app and try again.',
      ));
      return;
    }
    emit(state.copyWith(status: OverlayViewStatus.scanned, scrapedText: text));
  }

  Future<void> _onRead(RequestReadScreen event, Emitter<OverlayRuntimeState> emit) async {
    emit(state.copyWith(status: OverlayViewStatus.speaking, outputText: state.scrapedText));
    final lang = await AiAssistantService.getSelectedLanguage();
    await _ai.readText(state.scrapedText, lang);
  }

  Future<void> _onTranslate(RequestTranslate event, Emitter<OverlayRuntimeState> emit) async {
    emit(state.copyWith(status: OverlayViewStatus.processing));
    final lang = await AiAssistantService.getSelectedLanguage();
    final translated = await _ai.translateText(state.scrapedText, lang);
    emit(state.copyWith(status: OverlayViewStatus.speaking, outputText: translated));
    await _ai.readText(translated, lang);
  }

  Future<void> _onSummarize(RequestSummarize event, Emitter<OverlayRuntimeState> emit) async {
    emit(state.copyWith(status: OverlayViewStatus.processing));
    final lang = await AiAssistantService.getSelectedLanguage();
    final summary = await _ai.summarizeText(state.scrapedText, lang);
    emit(state.copyWith(status: OverlayViewStatus.speaking, outputText: summary));
    await _ai.readText(summary, lang);
  }

  Future<void> _onStop(StopSpeaking event, Emitter<OverlayRuntimeState> emit) async {
    await _ai.stopSpeaking();
    emit(state.copyWith(status: OverlayViewStatus.scanned));
  }
}
