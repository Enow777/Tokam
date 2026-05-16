import 'package:flutter/material.dart';
import 'package:tokam/core/constants/colors.dart';
import 'package:audioplayers/audioplayers.dart';

class LanguageSelectorScreen extends StatelessWidget {
  final AudioPlayer _player = AudioPlayer();

  final List<Map<String, String>> languages = [
    {'name': 'Cameroonian Pidgin', 'code': 'pcm', 'audio': 'pidgin_intro.mp3'},
    {'name': 'Ngemba', 'code': 'nge', 'audio': 'ngemba_intro.mp3'},
    {'name': 'Kom', 'code': 'kom', 'audio': 'kom_intro.mp3'},
    {'name': 'Meta', 'code': 'mta', 'audio': 'meta_intro.mp3'},
  ];

  LanguageSelectorScreen({super.key});

  void _playFeedback(String assetPath) async {
    await _player.play(AssetSource('audio/$assetPath'));
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
                "Select Your Language",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Choose the language you want the assistant to speak.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    return InkWell(
                      onTap: () {
                        _playFeedback(lang['audio']!);
                        // Save selection and navigate
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.primaryAccent.withValues(alpha: 0.1),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              size: 48,
                              color: AppColors.primaryAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              lang['name']!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Auth
                  },
                  child: const Text("CONTINUE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
