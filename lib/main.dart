import 'package:flutter/material.dart';
import 'package:tokam/core/theme/high_contrast_theme.dart';
import 'package:tokam/features/onboarding/presentation/screens/language_selector_screen.dart';
import 'package:tokam/features/overlay/presentation/windows/floating_bubble_element.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase is intentionally skipped until google-services.json is placed in android/app/
  // and SHA-1 is registered. The app functions fully without it for screen scanning & TTS.
  runApp(const OverlayApp());
}

/// Entry point for the Overlay Window (called by flutter_overlay_window)
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FloatingBubbleElement(),
    ),
  );
}

class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokam Assistant',
      debugShowCheckedModeBanner: false,
      theme: HighContrastTheme.light,
      darkTheme: HighContrastTheme.dark,
      themeMode: ThemeMode.system,
      home: const LanguageSelectorScreen(),
    );
  }
}
