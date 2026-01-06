// lib/features/fanverse/presentation/screens/fanverse_screen.dart
// 2.2 Fanverse - Main page with episodes
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class FanverseScreen extends StatelessWidget {
  const FanverseScreen({super.key});

  final List<Map<String, dynamic>> _episodes = const [
    {
      'id': 'ep01',
      'icon': '🎞️',
      'title': 'Poster Pose Remix',
      'desc': 'Recreate the iconic Magenta poster pose — same framing or your own twist. Attitude, expression and presence drive your score.',
      'episode': 'Episode 01',
      'tags': ['Photo', 'Solo / Duo', 'Pose • Framing'],
      'type': 'photo',
    },
    {
      'id': 'ep02',
      'icon': '🎬',
      'title': 'Scene for Scene',
      'desc': 'Pick an iconic Magenta moment and recreate it shot-for-shot — same beats, your location and your interpretation.',
      'episode': 'Episode 02',
      'tags': ['Short Video', 'Acting • Timing', 'Collab Friendly'],
      'type': 'video',
    },
    {
      'id': 'ep03',
      'icon': '💄',
      'title': 'Magenta Mode On',
      'desc': 'Transform into a Magenta-inspired look — makeup, outfit, lighting and attitude come together in one strong frame.',
      'episode': 'Episode 03',
      'tags': ['Photo / Video', 'Style • Mood', 'Glow-up'],
      'type': 'both',
    },
    {
      'id': 'ep04',
      'icon': '🎙️',
      'title': 'Dialog Drop',
      'desc': 'Lip-sync or act out a memorable Magenta line. Expression, delivery and screen presence define your impact.',
      'episode': 'Episode 04',
      'tags': ['Video', 'Dialog • Expression', 'Solo'],
      'type': 'video',
    },
    {
      'id': 'ep05',
      'icon': '🌀',
      'title': 'Behind the Fanverse',
      'desc': 'Show the process — BTS moments, edits, lighting setups or creative prep behind any Fanverse entry.',
      'episode': 'Episode 05',
      'tags': ['Video / Carousel', 'BTS • Process', 'Bonus Impact'],
      'type': 'video',
    },
    {
      'id': 'ep06',
      'icon': '💃',
      'title': 'MagentaMove',
      'desc': 'Recreate a Magenta song reel — nail the hook step or add your twist with timing, energy and clean cuts.',
      'episode': 'Episode 06',
      'tags': ['Reel / Video', 'Choreo • Timing', 'Music-led'],
      'type': 'video',
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
            colors: [Color(0xFF2B2148), Color(0xFF020214), Color(0xFF01000C)],
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
                    _buildSectionTitle('Fanverse Episodes'),
                    const SizedBox(height: 8),
                    ..._episodes.map((ep) => _buildEpisodeCard(context, ep)),
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
                colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF), Color(0xFF5CF1FF), Color(0xFFFF4FD8)],
              ),
              boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.6), blurRadius: 14)],
            ),
          ),
          const SizedBox(width: 10),
          const Text('SHOWGRID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4FD8).withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFF4FD8).withOpacity(0.5)),
            ),
            child: const Text('FANVERSE', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Color(0xFFFF4FD8))),
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
          colors: [Color(0xFF0B0C30), Color(0xFF040518)],
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
                gradient: RadialGradient(colors: [const Color(0xFFFF4FD8).withOpacity(0.22), Colors.transparent]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SHOWGRID ORIGINALS • FAN CHALLENGE SERIES', style: TextStyle(fontSize: 11, letterSpacing: 2.2, color: SGColors.htmlMuted)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  children: [
                    const TextSpan(text: 'Magenta\n', style: TextStyle(color: Colors.white)),
                    TextSpan(
                      text: 'Fanverse',
                      style: TextStyle(
                        foreground: Paint()..shader = const LinearGradient(
                          colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF), Color(0xFF5CF1FF)],
                        ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Step into the Magenta universe. Recreate iconic poses, scenes, moods and moments in your own style — where fandom meets performance.',
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

  Widget _buildEpisodeCard(BuildContext context, Map<String, dynamic> episode) {
    return GestureDetector(
      onTap: () => context.go('/fanverse/challenge/${episode['id']}', extra: episode),
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
                    gradient: const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]),
                  ),
                  child: Center(child: Text(episode['icon'], style: const TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(episode['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 3),
                      Text(episode['desc'], style: const TextStyle(fontSize: 11.5, color: SGColors.htmlMuted, height: 1.45)),
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
                  child: Text(episode['episode'], style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: SGColors.htmlMuted)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (episode['tags'] as List<String>).map((tag) => Container(
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
      {'num': '1', 'title': 'Pick an episode', 'sub': 'Choose your creative lane'},
      {'num': '2', 'title': 'Create your entry', 'sub': 'Photo or short video'},
      {'num': '3', 'title': 'Get scored', 'sub': 'AI score + fan ratings'},
      {'num': '4', 'title': 'Rise on Fanverse Grid', 'sub': 'Top fans get featured'},
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
          const Text('How Fanverse Works', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
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
                    gradient: LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]),
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
