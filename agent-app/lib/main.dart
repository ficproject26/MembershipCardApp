import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared/shared.dart';
import 'screens/agent_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize notification service in the background so it doesn't block UI rendering
  // Wrapped in try-catch to prevent black screen on emulators without Play Services
  try {
    NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification init failed (safe to ignore on emulator): $e');
  }
  
  // Prevent Google Fonts from blocking the main thread with network requests.
  // This avoids the black screen / 110 skipped frames on startup.
  // Fonts will use system fallback unless bundled as assets.
  // GoogleFonts.config.allowRuntimeFetching = false;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return MaterialApp(
      navigatorKey: sharedNavigatorKey,
      title: 'FIC Agent Portal',
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
      home: const AgentLoginScreen(),
    );
  }
}
