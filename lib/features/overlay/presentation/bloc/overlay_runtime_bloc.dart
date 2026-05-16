import 'package:flutter_bloc/flutter_bloc.dart';

// Discrete States
enum OverlayViewStatus { closed, listening, processing, speaking, dispatchReady }

class OverlayRuntimeState {
  final OverlayViewStatus currentStatus;
  final String activeScreenScrapedText;
  final String localVoicePlaybackTarget;

  OverlayRuntimeState({
    required this.currentStatus,
    this.activeScreenScrapedText = '',
    this.localVoicePlaybackTarget = '',
  });

  OverlayRuntimeState copyWith({
    OverlayViewStatus? currentStatus,
    String? activeScreenScrapedText,
    String? localVoicePlaybackTarget,
  }) {
    return OverlayRuntimeState(
      currentStatus: currentStatus ?? this.currentStatus,
      activeScreenScrapedText: activeScreenScrapedText ?? this.activeScreenScrapedText,
      localVoicePlaybackTarget: localVoicePlaybackTarget ?? this.localVoicePlaybackTarget,
    );
  }
}

// Concrete Execution Events
abstract class OverlayRuntimeEvent {}
class TriggerEngagementBubbleTap extends OverlayRuntimeEvent {}
class ScreenTextScrapeComplete extends OverlayRuntimeEvent { final String parsedText; ScreenTextScrapeComplete(this.parsedText); }
class OfflineTranslationComplete extends OverlayRuntimeEvent { final String spokenTextPath; OfflineTranslationComplete(this.spokenTextPath); }
class VoiceReadingFinished extends OverlayRuntimeEvent {}

// Bloc Processor Implementation Engine
class OverlayRuntimeBloc extends Bloc<OverlayRuntimeEvent, OverlayRuntimeState> {
  OverlayRuntimeBloc() : super(OverlayRuntimeState(currentStatus: OverlayViewStatus.closed)) {
    
    on<TriggerEngagementBubbleTap>((event, emit) {
      if (state.currentStatus == OverlayViewStatus.closed) {
        emit(state.copyWith(currentStatus: OverlayViewStatus.listening));
      } else {
        emit(state.copyWith(currentStatus: OverlayViewStatus.closed));
      }
    });

    on<ScreenTextScrapeComplete>((event, emit) {
      emit(state.copyWith(
        currentStatus: OverlayViewStatus.processing,
        activeScreenScrapedText: event.parsedText,
      ));
    });

    on<OfflineTranslationComplete>((event, emit) {
      emit(state.copyWith(
        currentStatus: OverlayViewStatus.speaking,
        localVoicePlaybackTarget: event.spokenTextPath,
      ));
    });

    on<VoiceReadingFinished>((event, emit) {
      emit(state.copyWith(currentStatus: OverlayViewStatus.dispatchReady));
    });
  }
}
