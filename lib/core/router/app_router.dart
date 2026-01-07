// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
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
import '../../features/rate/presentation/screens/rate_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OtpScreen(phoneNumber: extra?['phoneNumber'] ?? '', verificationId: extra?['verificationId'] ?? '');
      }),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/rate', builder: (context, state) => const RateScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/fortune', builder: (context, state) => const FortuneScreen()),
      GoRoute(path: '/fortune/challenge/:id', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ChallengeScreen(challengeId: state.pathParameters['id']!, challengeData: extra);
      }),
      GoRoute(path: '/fortune/photo/:id', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PhotoCaptureScreen(
          challengeId: state.pathParameters['id']!,
          challengeTitle: extra?['title'] ?? 'Challenge',
          challengeDescription: extra?['description'] ?? '',
          gridType: 'fortune',
        );
      }),
      GoRoute(path: '/fortune/video/:id', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return VideoCaptureScreen(
          challengeId: state.pathParameters['id']!,
          challengeTitle: extra?['title'] ?? 'Challenge',
          challengeDescription: extra?['description'] ?? '',
          gridType: 'fortune',
        );
      }),
      GoRoute(path: '/fanverse', builder: (context, state) => const FanverseScreen()),
      GoRoute(path: '/fanverse/challenge/:id', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ChallengeScreen(challengeId: state.pathParameters['id']!, challengeData: extra, gridType: 'fanverse');
      }),
      GoRoute(path: '/gridvoice', builder: (context, state) => const GridVoiceScreen()),
      GoRoute(path: '/gridvoice/challenge/:id', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ChallengeScreen(challengeId: state.pathParameters['id']!, challengeData: extra, gridType: 'gridvoice');
      }),
      GoRoute(path: '/discovery', builder: (context, state) => const DiscoveryScreen()),
      GoRoute(path: '/powerboard', builder: (context, state) => const PowerboardScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
  );
}
