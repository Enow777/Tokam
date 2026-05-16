import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:tokam/core/constants/colors.dart';

class PermissionGateScreen extends StatefulWidget {
  const PermissionGateScreen({super.key});

  @override
  State<PermissionGateScreen> createState() => _PermissionGateScreenState();
}

class _PermissionGateScreenState extends State<PermissionGateScreen>
    with WidgetsBindingObserver {
  bool _isOverlayGranted = false;
  bool _isAccessibilityGranted = false;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final overlay = await FlutterOverlayWindow.isPermissionGranted();
      if (mounted) {
        setState(() => _isOverlayGranted = overlay);
      }
    } catch (_) {}
  }

  void _requestOverlay() async {
    try {
      const intent = AndroidIntent(
        action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
        data: 'package:com.inclusion.cameroon.accessibility_overlay',
      );
      await intent.launch();
    } catch (_) {
      await FlutterOverlayWindow.requestPermission();
    }
  }

  void _requestAccessibility() async {
    const intent = AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
    );
    await intent.launch();
  }

  Future<void> _activateSystem() async {
    setState(() => _isActivating = true);
    try {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "Tokam Assistant",
        overlayContent: 'Tap the bubble to scan the screen',
        flag: OverlayFlag.defaultFlag,
        startPosition: const OverlayPosition(0, 200),
        height: 130,
        width: 130,
      );
      // If we get here the overlay launched successfully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tokam bubble is now active! Minimize this app and tap the bubble.'),
            duration: Duration(seconds: 4),
            backgroundColor: AppColors.successState,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase();
        String hint;
        if (msg.contains('permission') || msg.contains('overlay')) {
          hint = 'Please tap "Display Over Other Apps" above and enable the permission for Tokam.';
        } else {
          hint = 'Error: $e';
        }
        _showErrorDialog(hint);
      }
    }
    if (mounted) setState(() => _isActivating = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Could Not Activate'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestOverlay();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.security_rounded,
                        color: AppColors.primaryAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Setup Required',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('Complete these two steps then activate',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Step 1 — Overlay
              _StepTile(
                step: '1',
                icon: Icons.picture_in_picture_rounded,
                title: 'Display Over Other Apps',
                subtitle:
                    'Lets the Tokam bubble float over any screen. Tap to open Settings → enable for Tokam.',
                isGranted: _isOverlayGranted,
                onTap: _requestOverlay,
              ),
              const SizedBox(height: 16),

              // Step 2 — Accessibility
              _StepTile(
                step: '2',
                icon: Icons.accessibility_new_rounded,
                title: 'Accessibility Service',
                subtitle:
                    'Lets Tokam read screen text. Tap → find "Tokam" in the list → enable it.',
                isGranted: _isAccessibilityGranted,
                onTap: _requestAccessibility,
                trailing: _isAccessibilityGranted
                    ? null
                    : TextButton(
                        onPressed: () =>
                            setState(() => _isAccessibilityGranted = true),
                        child: const Text('Done ✓'),
                      ),
              ),
              const SizedBox(height: 20),

              // Info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: AppColors.primaryAccent, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap ACTIVATE even if the checkmarks are not showing — the button will still work.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.primaryAccent),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ACTIVATE button — ALWAYS enabled
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  // Always enabled — we handle errors gracefully inside
                  onPressed: _isActivating ? null : _activateSystem,
                  icon: _isActivating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.rocket_launch_rounded),
                  label: Text(
                    _isActivating ? 'Activating...' : 'ACTIVATE ASSISTANT',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step tile ────────────────────────────────────────────────────────────────
class _StepTile extends StatelessWidget {
  final String step;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback onTap;
  final Widget? trailing;

  const _StepTile({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isGranted
              ? AppColors.successState.withValues(alpha: 0.07)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted
                ? AppColors.successState
                : AppColors.primaryAccent.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Step badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isGranted
                    ? AppColors.successState
                    : AppColors.primaryAccent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isGranted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(step,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && !isGranted)
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.primaryAccent, size: 16),
          ],
        ),
      ),
    );
  }
}
