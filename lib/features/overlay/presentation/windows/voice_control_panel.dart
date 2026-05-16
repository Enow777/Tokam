import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tokam/core/constants/colors.dart';
import 'package:tokam/features/overlay/presentation/bloc/overlay_runtime_bloc.dart';

class VoiceControlPanel extends StatelessWidget {
  const VoiceControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OverlayRuntimeBloc(),
      child: const _VoiceControlPanelView(),
    );
  }
}

class _VoiceControlPanelView extends StatelessWidget {
  const _VoiceControlPanelView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OverlayRuntimeBloc, OverlayRuntimeState>(
      builder: (context, state) {
        Color statusColor;
        String statusText;

        switch (state.currentStatus) {
          case OverlayViewStatus.listening:
            statusColor = AppColors.primaryAccent;
            statusText = "Listening...";
            break;
          case OverlayViewStatus.processing:
            statusColor = AppColors.secondaryAccent;
            statusText = "Translating...";
            break;
          case OverlayViewStatus.speaking:
            statusColor = AppColors.successState;
            statusText = "Speaking...";
            break;
          default:
            statusColor = AppColors.primaryAccent;
            statusText = "Tap to Start";
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    context.read<OverlayRuntimeBloc>().add(TriggerEngagementBubbleTap());
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      state.currentStatus == OverlayViewStatus.listening
                          ? Icons.mic_rounded
                          : Icons.record_voice_over_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  state.activeScreenScrapedText.isNotEmpty
                      ? state.activeScreenScrapedText
                      : "Open an app and tap the bubble to get translation.",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
