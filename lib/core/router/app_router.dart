// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';

// Main screens
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/fortune/presentation/screens/fortune_screen.dart';
import '../../features/fortune/presentation/screens/challenge_screen.dart';
import '../../features/fortune/presentation/screens/photo_capture_screen.dart';
import '../../features/fortune/presentation/screens/video_capture_screen.dart';
import '../../features/fanverse/presentation/screens/fanverse_screen.dart';
import '../../features/gridvoice/presentation/screens/gridvoice_screen.dart';
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/powerboard/presentation/screens/powerboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // OTP
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpScreen(
            phoneNumber: extra?['phoneNumber'] ?? '',
            verificationId: extra?['verificationId'] ?? '',
          );
        },
      ),
      
      // Home
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Fortune Grid
      GoRoute(
        path: '/fortune',
        builder: (context, state) => const FortuneScreen(),
      ),
      GoRoute(
        path: '/fortune/challenge/:id',
        builder: (context, state) {
          final challengeId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChallengeScreen(
            challengeId: challengeId,
            challengeData: extra,
          );
        },
      ),
      GoRoute(
        path: '/fortune/photo/:id',
        builder: (context, state) {
          final challengeId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return PhotoCaptureScreen(
            challengeId: challengeId,
            challengeTitle: extra?['title'] ?? 'Challenge',
            challengeDescription: extra?['description'] ?? '',
            gridType: 'fortune',
            challengeCategory: extra?['zone'],
          );
        },
      ),
      GoRoute(
        path: '/fortune/video/:id',
        builder: (context, state) {
          final challengeId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return VideoCaptureScreen(
            challengeId: challengeId,
            challengeTitle: extra?['title'] ?? 'Challenge',
            challengeDescription: extra?['description'] ?? '',
            gridType: 'fortune',
            challengeCategory: extra?['zone'],
            maxDuration: extra?['maxDuration'] ?? 60,
          );
        },
      ),
      
      // Fanverse Grid
      GoRoute(
        path: '/fanverse',
        builder: (context, state) => const FanverseScreen(),
      ),
      GoRoute(
        path: '/fanverse/challenge/:id',
        builder: (context, state) {
          final episodeId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChallengeScreen(
            challengeId: episodeId,
            challengeData: extra,
            gridType: 'fanverse',
          );
        },
      ),
      GoRoute(
        path: '/fanverse/photo/:id',
        builder: (context, state) {
          final episodeId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return PhotoCaptureScreen(
            challengeId: episodeId,
            challengeTitle: extra?['title'] ?? 'Episode',
            challengeDescription: extra?['description'] ?? '',
            gridType: 'fanverse',
            challengeCategory: extra?['category'],
          );
        },
      ),
      GoRoute(
        path: '/fanverse/video/:id',
        builder: (context, state) {
          final episodeId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return VideoCaptureScreen(
            challengeId: episodeId,
            challengeTitle: extra?['title'] ?? 'Episode',
            challengeDescription: extra?['description'] ?? '',
            gridType: 'fanverse',
            challengeCategory: extra?['category'],
            maxDuration: 60,
          );
        },
      ),
      
      // GridVoice
      GoRoute(
        path: '/gridvoice',
        builder: (context, state) => const GridVoiceScreen(),
      ),
      GoRoute(
        path: '/gridvoice/challenge/:id',
        builder: (context, state) {
          final chapterId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChallengeScreen(
            challengeId: chapterId,
            challengeData: extra,
            gridType: 'gridvoice',
          );
        },
      ),
      
      // Discovery
      GoRoute(
        path: '/discovery',
        builder: (context, state) => const DiscoveryScreen(),
      ),
      
      // Powerboard
      GoRoute(
        path: '/powerboard',
        builder: (context, state) => const PowerboardScreen(),
      ),
      
      // Profile
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
