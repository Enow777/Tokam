import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tokam/core/theme/high_contrast_theme.dart';
import 'package:tokam/features/onboarding/presentation/screens/language_selector_screen.dart';
import 'package:tokam/features/overlay/presentation/windows/floating_bubble_element.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const OverlayApp());
}

// Entry point for the Overlay Window
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
      title: 'Linguistic Overlay',
      debugShowCheckedModeBanner: false,
      theme: HighContrastTheme.light,
      darkTheme: HighContrastTheme.dark,
      themeMode: ThemeMode.system,
      home: LanguageSelectorScreen(),
    );
  }
}
