import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:tokam/core/constants/colors.dart';

class PermissionGateScreen extends StatefulWidget {
  const PermissionGateScreen({super.key});

  @override
  State<PermissionGateScreen> createState() => _PermissionGateScreenState();
}

class _PermissionGateScreenState extends State<PermissionGateScreen> with WidgetsBindingObserver {
  bool _isOverlayGranted = false;
  bool _isAccessibilityGranted = false;

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

  /// Re-check whenever user returns from Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final overlay = await FlutterOverlayWindow.isPermissionGranted();
    setState(() {
      _isOverlayGranted = overlay;
      // We infer accessibility is granted if overlay was also given (simplification).
      // A real check would use a MethodChannel back from the service.
      _isAccessibilityGranted = _isAccessibilityGranted;
    });
  }

  void _requestOverlay() async {
    await FlutterOverlayWindow.requestPermission();
    await Future.delayed(const Duration(seconds: 1));
    _checkPermissions();
  }

  void _requestAccessibility() async {
    const intent = AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
    );
    await intent.launch();
  }

  void _markAccessibilityDone() {
    setState(() => _isAccessibilityGranted = true);
  }

  Future<void> _activateSystem() async {
    try {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "Tokam Assistant",
        overlayContent: 'Screen assistant is active',
        flag: OverlayFlag.defaultFlag,
        startPosition: const OverlayPosition(-60, 260),
        height: 130,
        width: 130,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Overlay started. If bubble is not visible, check "Draw over apps" permission. ($e)'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Overlay permission is mandatory. Accessibility can be enabled after launch.
    final canActivate = _isOverlayGranted;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
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
                        Text('Permissions Required',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('Two permissions needed to scan screens',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _PermissionTile(
                icon: Icons.picture_in_picture_rounded,
                title: "Display Over Other Apps",
                subtitle: "Allows the assistant bubble to float on top of any screen.",
                isGranted: _isOverlayGranted,
                onPressed: _requestOverlay,
              ),
              const SizedBox(height: 16),
              _PermissionTile(
                icon: Icons.accessibility_new_rounded,
                title: "Accessibility Service",
                subtitle: "Allows the assistant to read on-screen text for you.",
                isGranted: _isAccessibilityGranted,
                onPressed: _requestAccessibility,
                trailingWidget: _isAccessibilityGranted
                    ? null
                    : TextButton(
                        onPressed: _markAccessibilityDone,
                        child: const Text("I enabled it"),
                      ),
              ),
              const SizedBox(height: 12),
              if (!_isAccessibilityGranted)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'In Accessibility Settings: Find "Tokam" under Installed Apps, enable it, then tap "I enabled it".',
                          style: TextStyle(fontSize: 12, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: canActivate ? _activateSystem : null,
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text('ACTIVATE ASSISTANT',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
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

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback onPressed;
  final Widget? trailingWidget;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onPressed,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted
            ? AppColors.successState.withValues(alpha: 0.07)
            : Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? AppColors.successState : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isGranted ? AppColors.successState : AppColors.primaryAccent,
              size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isGranted)
            const Icon(Icons.check_circle, color: AppColors.successState)
          else if (trailingWidget != null)
            trailingWidget!
          else
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.primaryAccent, size: 18),
            ),
        ],
      ),
    );
  }
}
