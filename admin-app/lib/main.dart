import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared/shared.dart';
import 'screens/admin_login_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Background Firebase init error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: sharedNavigatorKey,
      title: 'FIC Admin Portal',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      
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
          surface: const Color(0xFF0C1017),
        ),
        useMaterial3: true,
      ),
      
      home: const AdminLoginScreen(),
    );
  }
}
