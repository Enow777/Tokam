import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tokam/core/services/ai_assistant_service.dart';
import 'package:tokam/features/history/data/history_repository.dart';
import 'package:tokam/features/history/domain/models/history_item.dart';

// ── States ──────────────────────────────────────────────────────────────────
enum OverlayViewStatus { idle, scanned, processing, speaking, chatting, error }

class OverlayRuntimeState {
  final OverlayViewStatus status;
  final String scrapedText;
  final String outputText;
  final String errorMessage;
  final String chatResponse;

  const OverlayRuntimeState({
    this.status = OverlayViewStatus.idle,
    this.scrapedText = '',
    this.outputText = '',
    this.errorMessage = '',
    this.chatResponse = '',
  });

  OverlayRuntimeState copyWith({
    OverlayViewStatus? status,
    String? scrapedText,
    String? outputText,
    String? errorMessage,
    String? chatResponse,
  }) =>
      OverlayRuntimeState(
        status: status ?? this.status,
        scrapedText: scrapedText ?? this.scrapedText,
        outputText: outputText ?? this.outputText,
        errorMessage: errorMessage ?? this.errorMessage,
        chatResponse: chatResponse ?? this.chatResponse,
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

/// User chose "Ask AI" action or submitted a chat message
class RequestChat extends OverlayRuntimeEvent {
  final String userMessage;
  RequestChat(this.userMessage);
}

/// Stop TTS playback
class StopSpeaking extends OverlayRuntimeEvent {}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class OverlayRuntimeBloc extends Bloc<OverlayRuntimeEvent, OverlayRuntimeState> {
  final AiAssistantService _ai;
  final HistoryRepository _history;

  OverlayRuntimeBloc({AiAssistantService? aiService, HistoryRepository? historyRepo})
      : _ai = aiService ?? AiAssistantService(),
        _history = historyRepo ?? HistoryRepository(),
        super(const OverlayRuntimeState()) {

    on<ScanCurrentScreen>(_onScan);
    on<RequestReadScreen>(_onRead);
    on<RequestTranslate>(_onTranslate);
    on<RequestSummarize>(_onSummarize);
    on<RequestChat>(_onChat);
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
    
    // Save to history
    await _history.saveItem(HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalText: state.scrapedText,
      resultText: translated,
      type: HistoryType.translation,
      timestamp: DateTime.now(),
    ));

    emit(state.copyWith(status: OverlayViewStatus.speaking, outputText: translated));
    await _ai.readText(translated, lang);
  }

  Future<void> _onSummarize(RequestSummarize event, Emitter<OverlayRuntimeState> emit) async {
    emit(state.copyWith(status: OverlayViewStatus.processing));
    final lang = await AiAssistantService.getSelectedLanguage();
    final summary = await _ai.summarizeText(state.scrapedText, lang);

    // Save to history
    await _history.saveItem(HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalText: state.scrapedText,
      resultText: summary,
      type: HistoryType.summary,
      timestamp: DateTime.now(),
    ));

    emit(state.copyWith(status: OverlayViewStatus.speaking, outputText: summary));
    await _ai.readText(summary, lang);
  }

  Future<void> _onStop(StopSpeaking event, Emitter<OverlayRuntimeState> emit) async {
    await _ai.stopSpeaking();
    emit(state.copyWith(status: OverlayViewStatus.scanned));
  }

  Future<void> _onChat(RequestChat event, Emitter<OverlayRuntimeState> emit) async {
    // If no message, just switch to chat view
    if (event.userMessage.isEmpty) {
      emit(state.copyWith(status: OverlayViewStatus.chatting));
      return;
    }

    emit(state.copyWith(status: OverlayViewStatus.processing));
    final lang = await AiAssistantService.getSelectedLanguage();
    
    // We use translateText internally for generic prompts for now
    // A proper conversational endpoint could be added to AiAssistantService
    final prompt = "Context from my screen: ${state.scrapedText}\n\nMy question: ${event.userMessage}\n\nAnswer concisely.";
    final answer = await _ai.translateText(prompt, lang); // Using existing API call structure

    // Save to history
    await _history.saveItem(HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalText: event.userMessage,
      resultText: answer,
      type: HistoryType.askAi,
      timestamp: DateTime.now(),
    ));

    emit(state.copyWith(
      status: OverlayViewStatus.chatting,
      chatResponse: answer,
    ));
  }
}
