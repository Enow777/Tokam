import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.inclusion.overlay/shortcut_manager');

  static Future<bool> pinShortcut() async {
    try {
      final bool success = await _channel.invokeMethod('executePinRequest');
      return success;
    } on PlatformException catch (e) {
      debugPrint("Failed to pin shortcut: '${e.message}'.");
      return false;
    }
  }

  // Add more bridge methods here for Accessibility/Overlay permission checks if needed natively
}
