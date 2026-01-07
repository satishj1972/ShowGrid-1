// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/utils/seed_data.dart';
import 'core/services/notification_service.dart';

// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Setup background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Seed initial data
  try {
    await SeedData.seedAllData();
  } catch (e) {
    print('Seed data error: $e');
  }
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF050507),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(const ProviderScope(child: ShowGridApp()));
}

class ShowGridApp extends StatelessWidget {
  const ShowGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShowGrid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050507),
        primaryColor: const Color(0xFF6C4AFF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C4AFF),
          secondary: Color(0xFFFF4FD8),
          surface: Color(0xFF0D0F1A),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
