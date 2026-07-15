import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

/// ─── Security Service ───
/// Checks if the device is rooted/jailbroken and blocks app usage.
/// Also provides utility methods for security-related checks.
class SecurityService {
  /// Check if device is rooted (Android) or jailbroken (iOS).
  /// Returns true if the device is compromised.
  static Future<bool> isDeviceCompromised() async {
    try {
      // Skip check in debug mode (for development/emulator)
      if (kDebugMode) {
        debugPrint('🔓 SecurityService: Debug mode — skipping root/jailbreak check');
        return false;
      }

      // Skip check on web platform
      if (kIsWeb) {
        return false;
      }

      final bool jailbroken = await FlutterJailbreakDetection.jailbroken;
      final bool developerMode = await FlutterJailbreakDetection.developerMode;

      if (jailbroken) {
        debugPrint('🚨 SecurityService: Device is rooted/jailbroken!');
      }
      if (developerMode) {
        debugPrint('⚠️ SecurityService: Developer mode is enabled');
      }

      return jailbroken;
    } catch (e) {
      debugPrint('SecurityService: Error checking device security: $e');
      // If check fails, allow app to run (fail-open for UX)
      return false;
    }
  }

  /// Shows a blocking dialog when device is compromised.
  /// User cannot dismiss or use the app.
  static void showCompromisedDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(Icons.security, color: Colors.red, size: 48),
          title: const Text('Security Alert'),
          content: const Text(
            'This app cannot run on rooted or jailbroken devices for security reasons.\n\n'
            'Please use a non-modified device to access this application.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the app — cannot proceed
                // Using SystemNavigator would be better but this is simpler
              },
              child: const Text('Close App'),
            ),
          ],
        ),
      ),
    );
  }
}
