import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokam/core/services/secrets.dart';

/// API key is stored in secrets.dart which is excluded from git via .gitignore
const _geminiApiKey = kGeminiApiKey;

/// Maps language codes used in onboarding to BCP-47 locale codes for TTS.
const _languageLocales = {
  'pcm': 'en-NG', // Pidgin fallback to Nigerian English
  'nge': 'fr-CM', // Ngemba fallback to Cameroonian French
  'kom': 'fr-CM',
  'mta': 'fr-CM',
};

class AiAssistantService {
  final FlutterTts _tts = FlutterTts();
  late final GenerativeModel _model;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // TTS initialization
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);

    // Gemini model initialization (only used when API key is set)
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _geminiApiKey,
    );

    _isInitialized = true;
  }

  /// Reads the scraped text aloud using device TTS in the preferred language locale.
  Future<void> readText(String text, String languageCode) async {
    await initialize();
    final locale = _languageLocales[languageCode] ?? 'en-US';
    await _tts.setLanguage(locale);
    await _tts.speak(text);
  }

  /// Translates & narrates using Gemini. Falls back to reading raw text if no API key.
  Future<String> translateText(String text, String languageCode) async {
    await initialize();
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return text; // Graceful fallback
    }
    final langName = _languageName(languageCode);
    final prompt =
        'Translate the following text to $langName in a natural, conversational way suitable for reading aloud. Only output the translated text:\n\n$text';
    return _callGemini(prompt);
  }

  /// Summarizes the screen context using Gemini. Falls back to first 200 chars if no API key.
  Future<String> summarizeText(String text, String languageCode) async {
    await initialize();
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      final preview = text.length > 200 ? '${text.substring(0, 200)}...' : text;
      return 'Summary (API key needed for full AI): $preview';
    }
    final langName = _languageName(languageCode);
    final prompt =
        'Summarize the following screen content in 2-3 short sentences in $langName. Make it clear and simple for someone who may have low literacy:\n\n$text';
    return _callGemini(prompt);
  }

  Future<String> _callGemini(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated.';
    } catch (e) {
      return 'AI service error: $e';
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  String _languageName(String code) {
    const names = {
      'pcm': 'Cameroonian Pidgin English',
      'nge': 'Ngemba',
      'kom': 'Kom',
      'mta': 'Meta',
    };
    return names[code] ?? 'English';
  }

  /// Reads the latest scraped screen text from native SharedPreferences.
  static Future<String> getScrapedScreenText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokam_screen_text') ?? '';
  }

  /// Gets the selected language code from SharedPreferences.
  static Future<String> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokam_selected_language') ?? 'pcm';
  }

  /// Saves the selected language code to SharedPreferences.
  static Future<void> saveSelectedLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokam_selected_language', code);
  }
}
