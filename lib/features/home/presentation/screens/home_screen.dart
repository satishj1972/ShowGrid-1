// lib/features/home/presentation/screens/home_screen.dart
// 2. HOME - Root hub with Fortune, Fanverse, GridVoice cards
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: SGColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 96),
                  children: [
                    _buildHero(),
                    const SizedBox(height: 16),
                    _buildSnapshot(),
                    const SizedBox(height: 22),
                    _buildSectionTitle('All Grids'),
                    const SizedBox(height: 14),
                    _buildGridStrip(
                      context,
                      meta: 'Participate',
                      title: 'Fortune Event Quest',
                      desc: 'Join real-world event challenges. Upload photos or videos. Win rewards.',
                      cta: 'View Quest →',
                      route: '/fortune',
                      gradient: [SGColors.htmlGold, SGColors.htmlPink],
                      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1600&auto=format&fit=crop',
                    ),
                    _buildGridStrip(
                      context,
                      meta: 'Create',
                      title: 'Magenta Fanverse',
                      desc: 'Recreate iconic scenes your way. Rated by AI and fans.',
                      cta: 'Enter Fanverse →',
                      route: '/fanverse',
                      gradient: [SGColors.htmlPink, SGColors.htmlViolet],
                      imageUrl: 'https://images.unsplash.com/photo-1524985069026-dd778a71c7b4?q=80&w=1600&auto=format&fit=crop',
                    ),
                    _buildGridStrip(
                      context,
                      meta: 'Discover',
                      title: 'GridVoice TN',
                      desc: 'Stories of people and places. Watch, listen, and vote.',
                      cta: 'Start Season →',
                      route: '/gridvoice',
                      gradient: [SGColors.htmlGreen, SGColors.htmlBlue],
                      imageUrl: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=1600&auto=format&fit=crop',
                    ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Row(
        children: [
          // Logo dot with conic gradient
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                startAngle: 2.4,
                colors: [Color(0xFFFF4FD8), Color(0xFFFFB84D), Color(0xFF5CF1FF), Color(0xFFFF4FD8)],
              ),
              boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.7), blurRadius: 14)],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'SHOWGRID',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SGColors.borderSubtle),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xF8080920), Color(0xF8030310)],
        ),
      ),
      child: Stack(
        children: [
          // Pink glow
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFFFF4FD8).withOpacity(0.22), Colors.transparent]),
              ),
            ),
          ),
          // Cyan glow
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF5CF1FF).withOpacity(0.22), Colors.transparent]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2),
                  children: [
                    const TextSpan(text: 'Three Worlds.\n', style: TextStyle(color: Colors.white)),
                    TextSpan(
                      text: 'One Grid.',
                      style: TextStyle(
                        foreground: Paint()..shader = const LinearGradient(
                          colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8), Color(0xFF5CF1FF)],
                        ).createShader(const Rect.fromLTWH(0, 0, 120, 30)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Participate, create, and discover stories across events, fandoms, and voices.',
                style: TextStyle(fontSize: 13, color: SGColors.htmlMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshot() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: SGColors.htmlGlass,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SGColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('🔥 Live challenges', style: TextStyle(fontSize: 12, color: Colors.white)),
          Text('⭐ AI + people ratings', style: TextStyle(fontSize: 12, color: Colors.white)),
          Text('🏆 Real winners', style: TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 13, letterSpacing: 1.8, color: SGColors.htmlMuted),
    );
  }

  Widget _buildGridStrip(
    BuildContext context, {
    required String meta,
    required String title,
    required String desc,
    required String cta,
    required String route,
    required List<Color> gradient,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SGColors.borderSubtle),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xF8080920), Color(0xF8030310)],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Image (60%)
            Expanded(
              flex: 6,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: gradient[0].withOpacity(0.3),
                    child: Center(child: Icon(Icons.image, color: gradient[0], size: 40)),
                  ),
                ),
              ),
            ),
            // Content (40%)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.toUpperCase(),
                          style: const TextStyle(fontSize: 10, letterSpacing: 1.8, color: SGColors.htmlMuted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: const TextStyle(fontSize: 12, color: Color(0xE0FFFFFF), height: 1.4),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(colors: [gradient[0], gradient[1], SGColors.htmlCyan]),
                        ),
                        child: Text(
                          cta.toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Color(0xFF050611)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
