import 'package:flutter/material.dart';
import 'package:tokam/core/constants/colors.dart';
import 'package:tokam/core/services/ai_assistant_service.dart';
import 'package:tokam/features/onboarding/presentation/screens/permission_gate_screen.dart';

class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  String? _selectedCode;

  final List<Map<String, String>> languages = [
    {'name': 'Cameroonian Pidgin', 'code': 'pcm', 'emoji': '🇨🇲'},
    {'name': 'Ngemba', 'code': 'nge', 'emoji': '🗣️'},
    {'name': 'Kom', 'code': 'kom', 'emoji': '🎙️'},
    {'name': 'Meta', 'code': 'mta', 'emoji': '🌍'},
  ];

  Future<void> _onSelect(String code) async {
    setState(() => _selectedCode = code);
    // Persist for use by overlay service
    await AiAssistantService.saveSelectedLanguage(code);
    // Preview TTS voice
    final ai = AiAssistantService();
    await ai.readText('Language selected.', code);
  }

  void _onContinue() {
    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language first.')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PermissionGateScreen()),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.translate_rounded,
                        color: AppColors.primaryAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Language',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('Tap to preview the voice',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = _selectedCode == lang['code'];
                    return GestureDetector(
                      onTap: () => _onSelect(lang['code']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryAccent.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryAccent
                                : Colors.grey.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lang['emoji']!,
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 10),
                            Text(
                              lang['name']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primaryAccent
                                    : null,
                              ),
                            ),
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(Icons.check_circle,
                                    color: AppColors.primaryAccent, size: 18),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('CONTINUE',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
