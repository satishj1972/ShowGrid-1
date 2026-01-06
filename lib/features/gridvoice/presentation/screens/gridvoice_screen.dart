// lib/features/gridvoice/presentation/screens/gridvoice_screen.dart
// 2.3 GridVoice - Main page with chapters
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class GridVoiceScreen extends StatelessWidget {
  const GridVoiceScreen({super.key});

  final List<Map<String, dynamic>> _chapters = const [
    {
      'id': 'ch01',
      'icon': '📸',
      'title': 'TN Through You',
      'desc': 'Show the Tamil Nadu you see every day — streets, routines, people, markets, travel, work and moments that feel real.',
      'chapter': 'Chapter 01',
      'tags': ['Photo / Video', 'Everyday Life', 'Storytelling'],
      'type': 'both',
    },
    {
      'id': 'ch02',
      'icon': '🌿',
      'title': 'Protect Our TN',
      'desc': 'Capture something worth preserving — nature, heritage, traditions, crafts or community spaces that define Tamil Nadu.',
      'chapter': 'Chapter 02',
      'tags': ['Photo / Video', 'Culture • Nature', 'Positive Impact'],
      'type': 'both',
    },
    {
      'id': 'ch03',
      'icon': '⚠️',
      'title': 'Fix Our TN',
      'desc': 'Show everyday civic issues visually — broken roads, waste, crowding, water issues or local challenges. Issue-focused, not political.',
      'chapter': 'Chapter 03',
      'tags': ['Photo', 'Civic Issues', 'Non-Political'],
      'type': 'photo',
    },
    {
      'id': 'ch04',
      'icon': '✨',
      'title': 'My TN 2.0',
      'desc': 'Capture a hopeful or futuristic version of Tamil Nadu — ideas, improvements, dreams or symbolic transformations.',
      'chapter': 'Chapter 04',
      'tags': ['Photo / Video', 'Future Vision', 'Creative'],
      'type': 'both',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFF1F2F3F), Color(0xFF020214), Color(0xFF01000C)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                  children: [
                    _buildHero(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('GridVoice Chapters'),
                    const SizedBox(height: 8),
                    ..._chapters.map((ch) => _buildChapterCard(context, ch)),
                    const SizedBox(height: 16),
                    _buildFlowSection(),
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

  Widget _buildHeader(BuildContext context) {
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
                colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF), Color(0xFF9B7DFF), Color(0xFF5CFFB1)],
              ),
              boxShadow: [BoxShadow(color: const Color(0xFF5CFFB1).withOpacity(0.6), blurRadius: 14)],
            ),
          ),
          const SizedBox(width: 10),
          const Text('SHOWGRID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF5CFFB1).withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.5)),
            ),
            child: const Text('GRIDVOICE', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Color(0xFF5CFFB1))),
          ),
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
          colors: [Color(0xFF0B1A30), Color(0xFF040518)],
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
                gradient: RadialGradient(colors: [const Color(0xFF5CFFB1).withOpacity(0.22), Colors.transparent]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SHOWGRID ORIGINALS • SEASON 1', style: TextStyle(fontSize: 11, letterSpacing: 2.2, color: SGColors.htmlMuted)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  children: [
                    const TextSpan(text: 'GridVoice\n', style: TextStyle(color: Colors.white)),
                    TextSpan(
                      text: 'Tamil Nadu',
                      style: TextStyle(
                        foreground: Paint()..shader = const LinearGradient(
                          colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF), Color(0xFF9B7DFF)],
                        ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A visual storytelling season capturing the real Tamil Nadu — its people, places, beauty, challenges and dreams. No scripts. No politics. Just stories.',
                style: TextStyle(fontSize: 13, color: SGColors.htmlMuted),
              ),
              const SizedBox(height: 12),
              // Audio feature highlight
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5CFFB1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.mic, color: Color(0xFF5CFFB1), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'New! Record voice stories with your photos & videos',
                        style: TextStyle(fontSize: 11, color: Color(0xFF5CFFB1)),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildChapterCard(BuildContext context, Map<String, dynamic> chapter) {
    return GestureDetector(
      onTap: () => context.go('/gridvoice/challenge/${chapter['id']}', extra: chapter),
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
                    gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
                  ),
                  child: Center(child: Text(chapter['icon'], style: const TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chapter['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 3),
                      Text(chapter['desc'], style: const TextStyle(fontSize: 11.5, color: SGColors.htmlMuted, height: 1.45)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0C24).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: Text(chapter['chapter'], style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: SGColors.htmlMuted)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (chapter['tags'] as List<String>).map((tag) => Container(
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
      {'num': '1', 'title': 'Pick a chapter', 'sub': 'Choose your story lane'},
      {'num': '2', 'title': 'Capture your story', 'sub': 'Photo, video or audio'},
      {'num': '3', 'title': 'Get scored', 'sub': 'AI GridScore + community ratings'},
      {'num': '4', 'title': 'Build your voice', 'sub': 'Your best stories define your season rank'},
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
          const Text('How GridVoice Works', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ...steps.map((step) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.12))),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
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
}
