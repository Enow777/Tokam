import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tokam/core/constants/colors.dart';
import 'package:tokam/features/overlay/presentation/bloc/overlay_runtime_bloc.dart';

/// Root widget for the overlay entry point (overlayMain).
/// Manages its own collapsed ↔ expanded state, resizing the
/// system window via FlutterOverlayWindow.resizeOverlay().
class OverlayEntryPoint extends StatefulWidget {
  const OverlayEntryPoint({super.key});

  @override
  State<OverlayEntryPoint> createState() => _OverlayEntryPointState();
}

class _OverlayEntryPointState extends State<OverlayEntryPoint>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _expand() async {
    if (mounted) setState(() => _isExpanded = true);
    try {
      await FlutterOverlayWindow.resizeOverlay(
        WindowSize.matchParent,
        WindowSize.matchParent,
        true,
      );
    } catch (e) {
      debugPrint("Expansion resize failed: $e");
    }
  }

  Future<void> _collapse() async {
    if (mounted) setState(() => _isExpanded = false);
    try {
      await FlutterOverlayWindow.resizeOverlay(130, 130, true);
    } catch (e) {
      debugPrint("Collapse resize failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpanded) {
      return BlocProvider(
        create: (_) => OverlayRuntimeBloc()..add(ScanCurrentScreen()),
        child: _ExpandedPanel(onClose: _collapse),
      );
    }
    return _CollapsedBubble(
      pulseController: _pulseController,
      onTap: _expand,
    );
  }
}

// ── Collapsed Bubble ──────────────────────────────────────────────────────────
class _CollapsedBubble extends StatelessWidget {
  final AnimationController pulseController;
  final VoidCallback onTap;

  const _CollapsedBubble({
    required this.pulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedBuilder(
            animation: pulseController,
            builder: (_, child) => Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryAccent, AppColors.secondaryAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(
                      alpha: 0.3 + 0.3 * pulseController.value,
                    ),
                    blurRadius: 10 + 8 * pulseController.value,
                    spreadRadius: 2 + 4 * pulseController.value,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Expanded Panel ────────────────────────────────────────────────────────────
class _ExpandedPanel extends StatelessWidget {
  final VoidCallback onClose;
  const _ExpandedPanel({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Tap outside to close
            Expanded(
              child: GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            _PanelBody(onClose: onClose),
          ],
        ),
      ),
    );
  }
}

class _PanelBody extends StatelessWidget {
  final VoidCallback onClose;
  const _PanelBody({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OverlayRuntimeBloc, OverlayRuntimeState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
              // Header
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
                  const Text('Screen Assistant',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      context.read<OverlayRuntimeBloc>().add(StopSpeaking());
                      onClose();
                    },
                    child:
                        const Icon(Icons.close, color: Colors.white54, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildBody(context, state),
              const SizedBox(height: 20),
              if (state.status == OverlayViewStatus.scanned ||
                  state.status == OverlayViewStatus.speaking)
                _ActionRow(
                  onRead: () =>
                      context.read<OverlayRuntimeBloc>().add(RequestReadScreen()),
                  onTranslate: () =>
                      context.read<OverlayRuntimeBloc>().add(RequestTranslate()),
                  onSummarize: () =>
                      context.read<OverlayRuntimeBloc>().add(RequestSummarize()),
                  isBusy: state.status == OverlayViewStatus.speaking,
                ),
              if (state.status == OverlayViewStatus.error ||
                  state.status == OverlayViewStatus.idle)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Scan Again',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: () =>
                        context.read<OverlayRuntimeBloc>().add(ScanCurrentScreen()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OverlayRuntimeState state) {
    switch (state.status) {
      case OverlayViewStatus.idle:
        return _StatusTile(
          icon: Icons.radar_rounded,
          color: AppColors.primaryAccent,
          title: 'Scanning screen...',
          subtitle: 'Reading visible content',
          showSpinner: true,
        );
      case OverlayViewStatus.scanned:
        return _PreviewCard(text: state.scrapedText);
      case OverlayViewStatus.processing:
        return _StatusTile(
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

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            showSpinner
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(color)))
                : Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _PreviewCard extends StatelessWidget {
  final String text;
  const _PreviewCard({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.successState, size: 16),
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
              text.length > 160 ? '${text.substring(0, 160)}...' : text,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      );
}

class _OutputCard extends StatelessWidget {
  final String text;
  const _OutputCard({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.secondaryAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.secondaryAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.volume_up_rounded,
                    color: AppColors.secondaryAccent, size: 16),
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
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.6),
            ),
          ],
        ),
      );
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
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              child: _Chip(
                  icon: Icons.hearing_rounded,
                  label: 'Read',
                  color: AppColors.primaryAccent,
                  onTap: isBusy ? null : onRead)),
          const SizedBox(width: 10),
          Expanded(
              child: _Chip(
                  icon: Icons.translate_rounded,
                  label: 'Translate',
                  color: AppColors.secondaryAccent,
                  onTap: isBusy ? null : onTranslate)),
          const SizedBox(width: 10),
          Expanded(
              child: _Chip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Summarize',
                  color: AppColors.successState,
                  onTap: isBusy ? null : onSummarize)),
        ],
      );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _Chip(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
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
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
      );
}
