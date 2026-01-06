// lib/features/fortune/presentation/screens/fortune_screen.dart
// 2.1 Fortune - Main page with challenges
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class FortuneScreen extends StatelessWidget {
  const FortuneScreen({super.key});

  final List<Map<String, dynamic>> _challenges = const [
    {
      'id': 'food',
      'icon': '🍜',
      'title': 'Food Grid Hunt',
      'desc': 'Capture the moment of the first bite — steam, chaos, smiles and the people behind the food.',
      'zone': 'Zone: Food Street',
      'tags': ['Photo / Short Video', 'Family • College'],
      'type': 'both',
    },
    {
      'id': 'style',
      'icon': '👗',
      'title': 'Style Street Runway',
      'desc': 'Turn walkways into your runway. Capture OOTDs, twirls, squad fits and bold street style moments.',
      'zone': 'Zone: Fashion Street',
      'tags': ['Video Preferred', 'Teens • Women'],
      'type': 'video',
    },
    {
      'id': 'family',
      'icon': '👨‍👩‍👧',
      'title': 'Family Frame Quest',
      'desc': 'One frame that captures your family vibe — laughter, chaos, grandparents and kids.',
      'zone': 'Zone: Any Zone',
      'tags': ['Photo', 'Family'],
      'type': 'photo',
    },
    {
      'id': 'college',
      'icon': '🎓',
      'title': 'College Crew Clash',
      'desc': 'Show your college gang energy — jump shots, mini performances or spontaneous squad moments.',
      'zone': 'Zone: Main Stage',
      'tags': ['Short Video', 'College Groups'],
      'type': 'video',
    },
    {
      'id': 'night',
      'icon': '🎡',
      'title': 'Night Lights Portrait',
      'desc': 'Use rides, neon lights and night colors as your backdrop — let the lights do the magic.',
      'zone': 'Zone: Rides / Neon',
      'tags': ['Photo', 'All'],
      'type': 'photo',
    },
    {
      'id': 'brand',
      'icon': '🏷️',
      'title': 'Brand Discovery Snap',
      'desc': 'Feature a stall or brand you loved — product, owner and you in one authentic frame or short clip.',
      'zone': 'Zone: Any Stall',
      'tags': ['Photo / Video', 'Support Local'],
      'type': 'both',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                  children: [
                    _buildHero(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('Quest Challenges'),
                    const SizedBox(height: 8),
                    ..._challenges.map((ch) => _buildChallengeCard(context, ch)),
                    const SizedBox(height: 16),
                    _buildFlowSection(),
                    const SizedBox(height: 16),
                    _buildCTA(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF030412).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                startAngle: 2.4,
                colors: [Color(0xFFFF4FD8), Color(0xFFFFB84D), Color(0xFF5CF1FF), Color(0xFFFF4FD8)],
              ),
              boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.6), blurRadius: 14)],
            ),
          ),
          const SizedBox(width: 10),
          const Text('SHOWGRID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0C30), Color(0xFF040518)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFFFFB84D).withOpacity(0.22), Colors.transparent]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EVENT QUEST • ERODE', style: TextStyle(fontSize: 11, letterSpacing: 2.2, color: SGColors.htmlMuted)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  children: [
                    const TextSpan(text: 'Fortune Event\n', style: TextStyle(color: Colors.white)),
                    TextSpan(
                      text: 'Quest Series',
                      style: TextStyle(
                        foreground: Paint()..shader = const LinearGradient(
                          colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8), Color(0xFF5CF1FF)],
                        ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A real-world grid of challenges across food, fashion, family and college zones. Capture on-ground moments and climb the Fortune Grid.',
                style: TextStyle(fontSize: 13, color: SGColors.htmlMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(), style: const TextStyle(fontSize: 13, letterSpacing: 1.8, color: SGColors.htmlMuted));
  }

  Widget _buildChallengeCard(BuildContext context, Map<String, dynamic> challenge) {
    return GestureDetector(
      onTap: () => context.go('/fortune/challenge/${challenge['id']}', extra: challenge),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF07081C).withOpacity(0.98),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8)]),
                  ),
                  child: Center(child: Text(challenge['icon'], style: const TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 3),
                      Text(challenge['desc'], style: const TextStyle(fontSize: 11.5, color: SGColors.htmlMuted, height: 1.45)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0A24).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: Text(challenge['zone'], style: const TextStyle(fontSize: 10, letterSpacing: 1.0, color: SGColors.htmlMuted)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (challenge['tags'] as List<String>).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0E28).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Text(tag.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 0.8, color: SGColors.htmlMuted)),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowSection() {
    final steps = [
      {'num': '1', 'title': 'Pick a challenge', 'sub': 'Choose a zone'},
      {'num': '2', 'title': 'Upload your moment', 'sub': 'Photo or short video'},
      {'num': '3', 'title': 'Get scored', 'sub': 'AI GridScore + ratings'},
      {'num': '4', 'title': 'Climb the Fortune Grid', 'sub': 'Best entries define your rank'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SGColors.htmlGlass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How Fortune Works', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ...steps.map((step) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.12), style: BorderStyle.solid)),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8)]),
                  ),
                  child: Center(child: Text(step['num']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF050611)))),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step['title']!, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text(step['sub']!, style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text('Your best entry per zone feeds your Fortune rank.', style: TextStyle(fontSize: 11.5, color: SGColors.htmlMuted)),
        ),
        GestureDetector(
          onTap: () => context.go('/fortune/challenge/food'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8), Color(0xFF5CF1FF)]),
            ),
            child: const Text('START FORTUNE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFF050611))),
          ),
        ),
      ],
    );
  }
}
