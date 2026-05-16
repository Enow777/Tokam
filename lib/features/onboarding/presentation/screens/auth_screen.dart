import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:tokam/core/constants/colors.dart';
import 'package:tokam/features/onboarding/presentation/screens/permission_gate_screen.dart' as tokam;

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!context.mounted) return;
      // Navigate to Permissions (Implementation pending navigation setup)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const tokam.PermissionGateScreen()),
      );
    } catch (e) {
      if (e.toString().contains("network_error") || e.toString().contains("SocketException")) {
        // Handle offline scenario during first-time launch
        final prefs = EncryptedSharedPreferences();
        await prefs.setString('offline_intent_token', 'cached_auth_intent');
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Offline mode. Intent cached for later sync.")),
        );
        // Still proceed to next screen for offline usage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const tokam.PermissionGateScreen()),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication Failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security_rounded,
                size: 80,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(height: 24),
              Text(
                "Secure Identity",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                "Verify your identity using Google to access offline language packs.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _signInWithGoogle(context),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text("SIGN IN WITH GOOGLE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
