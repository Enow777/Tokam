import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tokam/core/constants/colors.dart';
import 'package:tokam/features/overlay/presentation/bloc/overlay_runtime_bloc.dart';

/// The full-panel overlay shown when the floating bubble is expanded.
/// Mimics Gemini's screen context menu with three actions:
/// Read Screen | Translate | Summarize
class VoiceControlPanel extends StatelessWidget {
  const VoiceControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OverlayRuntimeBloc()..add(ScanCurrentScreen()),
      child: const _PanelView(),
    );
  }
}

class _PanelView extends StatelessWidget {
  const _PanelView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OverlayRuntimeBloc, OverlayRuntimeState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.screen_search_desktop_rounded,
                            color: AppColors.primaryAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Screen Assistant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Close / Stop button
                      GestureDetector(
                        onTap: () {
                          context.read<OverlayRuntimeBloc>().add(StopSpeaking());
                        },
                        child: const Icon(Icons.close, color: Colors.white54, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── State-based body ──────────────────────────────────────
                  _buildBody(context, state),
                  const SizedBox(height: 20),

                  // ── 3-Action Buttons (only when text is scanned) ─────────
                  if (state.status == OverlayViewStatus.scanned ||
                      state.status == OverlayViewStatus.speaking) ...[
                    _ActionRow(
                      onRead: () => context.read<OverlayRuntimeBloc>().add(RequestReadScreen()),
                      onTranslate: () => context.read<OverlayRuntimeBloc>().add(RequestTranslate()),
                      onSummarize: () => context.read<OverlayRuntimeBloc>().add(RequestSummarize()),
                      isBusy: state.status == OverlayViewStatus.speaking,
                    ),
                  ],

                  // Rescan button
                  if (state.status == OverlayViewStatus.error ||
                      state.status == OverlayViewStatus.idle)
                    _RescanButton(
                      onTap: () => context.read<OverlayRuntimeBloc>().add(ScanCurrentScreen()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OverlayRuntimeState state) {
    switch (state.status) {
      case OverlayViewStatus.idle:
        return const _StatusTile(
          icon: Icons.radar_rounded,
          color: AppColors.primaryAccent,
          title: 'Scanning screen...',
          subtitle: 'Reading visible content',
        );

      case OverlayViewStatus.scanned:
        return _ScrapedPreviewCard(text: state.scrapedText);

      case OverlayViewStatus.processing:
        return const _StatusTile(
          icon: Icons.auto_awesome_rounded,
          color: AppColors.secondaryAccent,
          title: 'AI is thinking...',
          subtitle: 'Connecting to Gemini',
          showSpinner: true,
        );

      case OverlayViewStatus.speaking:
        return _OutputCard(text: state.outputText);

      case OverlayViewStatus.error:
        return _StatusTile(
          icon: Icons.warning_amber_rounded,
          color: Colors.orangeAccent,
          title: 'Nothing detected',
          subtitle: state.errorMessage,
        );
    }
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool showSpinner;

  const _StatusTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          showSpinner
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrapedPreviewCard extends StatelessWidget {
  final String text;
  const _ScrapedPreviewCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.successState, size: 16),
              SizedBox(width: 6),
              Text('Screen scanned',
                  style: TextStyle(
                      color: AppColors.successState,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text.length > 180 ? '${text.substring(0, 180)}...' : text,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _OutputCard extends StatelessWidget {
  final String text;
  const _OutputCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.volume_up_rounded, color: AppColors.secondaryAccent, size: 16),
              SizedBox(width: 6),
              Text('Speaking...',
                  style: TextStyle(
                      color: AppColors.secondaryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text.length > 200 ? '${text.substring(0, 200)}...' : text,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onRead;
  final VoidCallback onTranslate;
  final VoidCallback onSummarize;
  final bool isBusy;

  const _ActionRow({
    required this.onRead,
    required this.onTranslate,
    required this.onSummarize,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.hearing_rounded,
            label: 'Read',
            color: AppColors.primaryAccent,
            onTap: isBusy ? null : onRead,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionChip(
            icon: Icons.translate_rounded,
            label: 'Translate',
            color: AppColors.secondaryAccent,
            onTap: isBusy ? null : onTranslate,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionChip(
            icon: Icons.auto_awesome_rounded,
            label: 'Summarize',
            color: AppColors.successState,
            onTap: isBusy ? null : onSummarize,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RescanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RescanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Scan Screen Again', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: onTap,
      ),
    );
  }
}
