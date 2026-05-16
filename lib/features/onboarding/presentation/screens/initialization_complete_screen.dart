import 'package:flutter/material.dart';
import 'package:tokam/core/constants/colors.dart';
import 'package:tokam/core/services/native_bridge.dart';

class InitializationCompleteScreen extends StatelessWidget {
  const InitializationCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 100,
                color: AppColors.successState,
              ),
              const SizedBox(height: 32),
              Text(
                "Setup Complete!",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                "Your linguistic assistant is ready. We will now pin a shortcut to your home screen for quick access.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await NativeBridge.pinShortcut();
                    // Close app gracefully
                  },
                  child: const Text("PIN SHORTCUT & FINISH"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
