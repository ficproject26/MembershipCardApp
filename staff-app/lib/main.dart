import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared/shared.dart';
import 'screens/staff_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase or Notification initialization failed: $e');
  }

  // ─── Security: Check for rooted/jailbroken device ───
  final isCompromised = await SecurityService.isDeviceCompromised();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],
      child: MyApp(isDeviceCompromised: isCompromised),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isDeviceCompromised;

  const MyApp({super.key, this.isDeviceCompromised = false});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return MaterialApp(
      navigatorKey: sharedNavigatorKey,
      title: 'FIC Staff Portal',
      debugShowCheckedModeBanner: false,
      themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // FIC Membership Club Light Theme (Gold + Navy Blue)
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF1A3B6E),
          primary: const Color(0xFF1A3B6E),
          secondary: const Color(0xFFFFC107),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      ),

      // FIC Membership Club Dark Theme (Gold + Deep Navy)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF1A3B6E),
          primary: const Color(0xFFFFC107),
          secondary: const Color(0xFF1A3B6E),
          surface: const Color(0xFF0D1B2A),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return IncomingCallOverlay(child: child!);
      },
      home: isDeviceCompromised
          ? const _CompromisedDeviceScreen()
          : const StaffLoginScreen(),
    );
  }
}

/// ─── Security: Blocking screen for rooted/jailbroken devices ───
class _CompromisedDeviceScreen extends StatelessWidget {
  const _CompromisedDeviceScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              Text(
                'Security Alert',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This app cannot run on rooted or jailbroken devices for security reasons.\n\n'
                'Please use a non-modified device to access this application.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

