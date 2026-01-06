// lib/core/router/app_router.dart
// ShowGrid Complete Router - All screens from sitemap
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';

// Home screen
import '../../features/home/presentation/screens/home_screen.dart';

// Fortune screens
import '../../features/fortune/presentation/screens/fortune_screen.dart';
import '../../features/fortune/presentation/screens/fortune_challenge_screen.dart';
import '../../features/fortune/presentation/screens/fortune_live_upload_screen.dart';
import '../../features/fortune/presentation/screens/fortune_photo_capture_screen.dart';
import '../../features/fortune/presentation/screens/fortune_video_capture_screen.dart';
import '../../features/fortune/presentation/screens/fortune_upload_screen.dart';

// Fanverse screens
import '../../features/fanverse/presentation/screens/fanverse_screen.dart';
import '../../features/fanverse/presentation/screens/fanverse_challenge_screen.dart';
import '../../features/fanverse/presentation/screens/fanverse_live_upload_screen.dart';
import '../../features/fanverse/presentation/screens/fanverse_photo_capture_screen.dart';
import '../../features/fanverse/presentation/screens/fanverse_video_capture_screen.dart';
import '../../features/fanverse/presentation/screens/fanverse_upload_screen.dart';

// GridVoice screens
import '../../features/gridvoice/presentation/screens/gridvoice_screen.dart';
import '../../features/gridvoice/presentation/screens/gridvoice_challenge_screen.dart';
import '../../features/gridvoice/presentation/screens/gridvoice_live_upload_screen.dart';
import '../../features/gridvoice/presentation/screens/gridvoice_audio_screen.dart';
import '../../features/gridvoice/presentation/screens/gridvoice_upload_screen.dart';

// Other main screens
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/powerboard/presentation/screens/powerboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // ============================================
      // 1. APP ENTRY FLOW
      // ============================================
      GoRoute(path: '/', name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/otp', name: 'otp', builder: (context, state) => const OTPScreen()),

      // ============================================
      // 2. HOME (ROOT HUB)
      // ============================================
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen()),

      // ============================================
      // 2.1 FORTUNE ROUTES
      // ============================================
      GoRoute(path: '/fortune', name: 'fortune', builder: (context, state) => const FortuneScreen()),
      GoRoute(
        path: '/fortune/challenge/:challengeId',
        name: 'fortune-challenge',
        builder: (context, state) {
          final challengeId = state.pathParameters['challengeId'] ?? '';
          final challengeData = state.extra as Map<String, dynamic>?;
          return FortuneChallengeScreen(challengeId: challengeId, challengeData: challengeData);
        },
      ),
      GoRoute(
        path: '/fortune/live/:challengeId',
        name: 'fortune-live',
        builder: (context, state) {
          final challengeId = state.pathParameters['challengeId'] ?? '';
          final challengeData = state.extra as Map<String, dynamic>?;
          return FortuneLiveUploadScreen(challengeId: challengeId, challengeData: challengeData);
        },
      ),
      // Fortune Photo/Video/Upload flows use dedicated Fortune screens
      GoRoute(
        path: '/fortune/photo/:challengeId',
        name: 'fortune-photo',
        builder: (context, state) {
          final challengeId = state.pathParameters['challengeId'] ?? '';
          final challengeData = state.extra as Map<String, dynamic>?;
          return FortunePhotoCaptureScreen(challengeId: challengeId, challengeData: challengeData);
        },
      ),
      GoRoute(
        path: '/fortune/video/:challengeId',
        name: 'fortune-video',
        builder: (context, state) {
          final challengeId = state.pathParameters['challengeId'] ?? '';
          final challengeData = state.extra as Map<String, dynamic>?;
          return FortuneVideoCaptureScreen(challengeId: challengeId, challengeData: challengeData);
        },
      ),
      GoRoute(
        path: '/fortune/upload/:challengeId',
        name: 'fortune-upload',
        builder: (context, state) {
          final challengeId = state.pathParameters['challengeId'] ?? '';
          final challengeData = state.extra as Map<String, dynamic>?;
          return FortuneUploadScreen(challengeId: challengeId, challengeData: challengeData);
        },
      ),

      // ============================================
      // 2.2 FANVERSE ROUTES
      // ============================================
      GoRoute(path: '/fanverse', name: 'fanverse', builder: (context, state) => const FanverseScreen()),
      GoRoute(
        path: '/fanverse/challenge/:episodeId',
        name: 'fanverse-challenge',
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId'] ?? '';
          final episodeData = state.extra as Map<String, dynamic>?;
          return FanverseChallengeScreen(episodeId: episodeId, episodeData: episodeData);
        },
      ),
      GoRoute(
        path: '/fanverse/live/:episodeId',
        name: 'fanverse-live',
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId'] ?? '';
          final episodeData = state.extra as Map<String, dynamic>?;
          return FanverseLiveUploadScreen(episodeId: episodeId, episodeData: episodeData);
        },
      ),
      GoRoute(
        path: '/fanverse/photo/:episodeId',
        name: 'fanverse-photo',
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId'] ?? '';
          final episodeData = state.extra as Map<String, dynamic>?;
          return FanversePhotoCaptureScreen(episodeId: episodeId, episodeData: episodeData);
        },
      ),
      GoRoute(
        path: '/fanverse/video/:episodeId',
        name: 'fanverse-video',
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId'] ?? '';
          final episodeData = state.extra as Map<String, dynamic>?;
          return FanverseVideoCaptureScreen(episodeId: episodeId, episodeData: episodeData);
        },
      ),
      GoRoute(
        path: '/fanverse/upload/:episodeId',
        name: 'fanverse-upload',
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId'] ?? '';
          final episodeData = state.extra as Map<String, dynamic>?;
          return FanverseUploadScreen(episodeId: episodeId, episodeData: episodeData);
        },
      ),

      // ============================================
      // 2.3 GRIDVOICE ROUTES
      // ============================================
      GoRoute(path: '/gridvoice', name: 'gridvoice', builder: (context, state) => const GridVoiceScreen()),
      GoRoute(
        path: '/gridvoice/challenge/:chapterId',
        name: 'gridvoice-challenge',
        builder: (context, state) {
          final chapterId = state.pathParameters['chapterId'] ?? '';
          final chapterData = state.extra as Map<String, dynamic>?;
          return GridVoiceChallengeScreen(chapterId: chapterId, chapterData: chapterData);
        },
      ),
      GoRoute(
        path: '/gridvoice/live/:chapterId',
        name: 'gridvoice-live',
        builder: (context, state) {
          final chapterId = state.pathParameters['chapterId'] ?? '';
          final chapterData = state.extra as Map<String, dynamic>?;
          return GridVoiceLiveUploadScreen(chapterId: chapterId, chapterData: chapterData);
        },
      ),
      GoRoute(
        path: '/gridvoice/audio/:chapterId',
        name: 'gridvoice-audio',
        builder: (context, state) {
          final chapterId = state.pathParameters['chapterId'] ?? '';
          final chapterData = state.extra as Map<String, dynamic>?;
          return GridVoiceAudioScreen(chapterId: chapterId, chapterData: chapterData);
        },
      ),
      GoRoute(
        path: '/gridvoice/upload/:chapterId',
        name: 'gridvoice-upload',
        builder: (context, state) {
          final chapterId = state.pathParameters['chapterId'] ?? '';
          final chapterData = state.extra as Map<String, dynamic>?;
          return GridVoiceUploadScreen(chapterId: chapterId, chapterData: chapterData);
        },
      ),

      // ============================================
      // 3. DISCOVERY
      // ============================================
      GoRoute(path: '/discover', name: 'discover', builder: (context, state) => const DiscoveryScreen()),

      // ============================================
      // 4. POWERBOARD
      // ============================================
      GoRoute(path: '/powerboard', name: 'powerboard', builder: (context, state) => const PowerboardScreen()),

      // ============================================
      // 5. PROFILE
      // ============================================
      GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Go to Home')),
          ],
        ),
      ),
    ),
  );
}
