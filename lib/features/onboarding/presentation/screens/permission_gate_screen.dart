import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:tokam/core/constants/colors.dart';

class PermissionGateScreen extends StatefulWidget {
  const PermissionGateScreen({super.key});

  @override
  State<PermissionGateScreen> createState() => _PermissionGateScreenState();
}

class _PermissionGateScreenState extends State<PermissionGateScreen> {
  bool _isOverlayGranted = false;
  bool _isAccessibilityGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final overlay = await FlutterOverlayWindow.isPermissionGranted();
    // For Accessibility, we might need a custom check via MethodChannel or a plugin
    // For now, we'll assume a way to check exists
    setState(() {
      _isOverlayGranted = overlay;
      _isAccessibilityGranted = false; // Mocked check
    });
  }

  void _requestOverlay() async {
    await FlutterOverlayWindow.requestPermission();
    _checkPermissions();
  }

  void _requestAccessibility() async {
    const intent = AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
    );
    await intent.launch();
    // After returning, the user should have enabled it
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
              Text(
                "Permissions Required",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _PermissionTile(
                title: "Display Over Other Apps",
                subtitle: "Allows the assistant bubble to float on your screen.",
                isGranted: _isOverlayGranted,
                onPressed: _requestOverlay,
              ),
              const SizedBox(height: 16),
              _PermissionTile(
                title: "Accessibility Service",
                subtitle: "Allows the assistant to read the screen text for you.",
                isGranted: _isAccessibilityGranted,
                onPressed: _requestAccessibility,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isOverlayGranted && _isAccessibilityGranted)
                      ? () {
                          // Navigate to next
                        }
                      : null,
                  child: const Text("ACTIVATE SYSTEM"),
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
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback onPressed;

  const _PermissionTile({
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted ? AppColors.successState.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? AppColors.successState : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(subtitle),
              ],
            ),
          ),
          IconButton(
            onPressed: isGranted ? null : onPressed,
            icon: Icon(
              isGranted ? Icons.check_circle : Icons.arrow_forward_ios,
              color: isGranted ? AppColors.successState : AppColors.primaryAccent,
            ),
          ),
        ],
      ),
    );
  }
}
