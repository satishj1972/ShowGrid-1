// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';
import '../../../../core/widgets/notification_bell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildHeroBanner(context),
                _buildRateCard(context),
                _buildGridCards(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(startAngle: 2.4, colors: [Color(0xFFFF4FD8), Color(0xFFFFB84D), Color(0xFF5CF1FF), Color(0xFFFF4FD8)]),
            ),
          ),
          const SizedBox(width: 10),
          const Text('SHOWGRID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
          const Spacer(),
          const NotificationBell(),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
        border: Border.all(color: SGColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: [SGColors.htmlViolet, SGColors.htmlPink, SGColors.htmlCyan]).createShader(bounds),
            child: const Text('Shine Your Grid', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          const Text('Compete. Create. Conquer.', style: TextStyle(fontSize: 14, color: SGColors.htmlMuted)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/fortune'),
            style: ElevatedButton.styleFrom(backgroundColor: SGColors.htmlViolet, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: const Text('Start Challenge'),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/rate'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [SGColors.htmlPink.withOpacity(0.3), SGColors.htmlViolet.withOpacity(0.3)]),
          border: Border.all(color: SGColors.htmlPink.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: SGColors.htmlPink.withOpacity(0.2)),
              child: const Icon(Icons.star_rate, color: SGColors.htmlPink, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rate Entries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('Help others and earn rewards!', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: SGColors.htmlPink, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Choose Your Grid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          _gridCard(context, 'Fortune Grid', 'Real-world challenges', Icons.emoji_events, SGColors.htmlGold, '/fortune'),
          const SizedBox(height: 12),
          _gridCard(context, 'Fanverse', 'Pop culture recreations', Icons.movie, SGColors.htmlPink, '/fanverse'),
          const SizedBox(height: 12),
          _gridCard(context, 'GridVoice', 'Audio storytelling', Icons.mic, SGColors.htmlGreen, '/gridvoice'),
        ],
      ),
    );
  }

  Widget _gridCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: SGColors.htmlGlass,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: color.withOpacity(0.15)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
