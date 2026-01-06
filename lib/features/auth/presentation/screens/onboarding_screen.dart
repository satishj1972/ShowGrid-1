// lib/features/auth/presentation/screens/onboarding_screen.dart
// 1.1, 1.11, 1.111 - Onboarding screens (3 slides)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'tag': '◆ ShowGrid · Visual Platform',
      'title': 'Create with Clarity',
      'subtitle': 'Your photos and videos, understood — not lost.',
      'cards': [
        {'icon': '🤖', 'title': 'Smart Feedback', 'desc': 'Clear visual signals.'},
        {'icon': '🧩', 'title': 'Structured Grids', 'desc': 'Themes over feeds.'},
        {'icon': '👥', 'title': 'Create Together', 'desc': 'With people who care.'},
      ],
    },
    {
      'tag': '◆ ShowGrid · Insights',
      'title': 'Understand What Works',
      'subtitle': 'Less guessing. More insight.',
      'cards': [
        {'icon': '⚡', 'title': 'Real-Time Signals', 'desc': 'Instant feedback on your content.'},
        {'icon': '🌍', 'title': 'Discover Beyond You', 'desc': 'Explore what others create.'},
        {'icon': '📈', 'title': 'Track Progress', 'desc': 'See how you improve over time.'},
      ],
    },
    {
      'tag': '◆ ShowGrid · Experience',
      'title': 'One Grid. Many Ways.',
      'subtitle': 'Participate or explore.',
      'cards': [
        {'icon': '🎯', 'title': 'Themed Moments', 'desc': 'Join structured challenges.'},
        {'icon': '🔍', 'title': 'Explore Freely', 'desc': 'Browse at your own pace.'},
        {'icon': '🧭', 'title': 'You\'re in Control', 'desc': 'Your journey, your choice.'},
      ],
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      color: SGColors.htmlCyan,
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) => _buildSlide(_slides[index]),
              ),
            ),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? SGColors.htmlCyan
                        : Colors.white.withOpacity(0.3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF007BFF)],
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          // Tag
          Text(
            slide['tag'],
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            slide['title'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            slide['subtitle'],
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 32),
          // Cards
          ...List.generate(
            (slide['cards'] as List).length,
            (index) => _buildCard(slide['cards'][index]),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, String> card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(card['icon']!, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card['title']!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card['desc']!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
