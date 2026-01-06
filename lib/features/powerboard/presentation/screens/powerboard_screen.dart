// lib/features/powerboard/presentation/screens/powerboard_screen.dart
// 4. Powerboard - All Season Ranking
import 'package:flutter/material.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class PowerboardScreen extends StatefulWidget {
  const PowerboardScreen({super.key});

  @override
  State<PowerboardScreen> createState() => _PowerboardScreenState();
}

class _PowerboardScreenState extends State<PowerboardScreen> {
  int _currentTab = 0;
  final List<String> _tabs = ['By Challenge', 'By Category', 'Global', 'Seasonal'];

  final List<Map<String, dynamic>> _rankings = [
    {'rank': 1, 'user': '@foodie.sam', 'score': 9.45, 'entries': 12, 'badge': '🥇'},
    {'rank': 2, 'user': '@magenta.fan', 'score': 9.35, 'entries': 10, 'badge': '🥈'},
    {'rank': 3, 'user': '@tn.stories', 'score': 9.25, 'entries': 15, 'badge': '🥉'},
    {'rank': 4, 'user': '@street.style', 'score': 9.10, 'entries': 8, 'badge': ''},
    {'rank': 5, 'user': '@pose.queen', 'score': 9.05, 'entries': 11, 'badge': ''},
    {'rank': 6, 'user': '@village.voice', 'score': 8.95, 'entries': 9, 'badge': ''},
    {'rank': 7, 'user': '@local.lens', 'score': 8.85, 'entries': 7, 'badge': ''},
    {'rank': 8, 'user': '@event.hunter', 'score': 8.75, 'entries': 14, 'badge': ''},
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
              _buildTabs(),
              const SizedBox(height: 16),
              _buildTopThree(),
              const SizedBox(height: 16),
              Expanded(child: _buildRankingsList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(startAngle: 2.4, colors: [Color(0xFFFF4FD8), Color(0xFFFFB84D), Color(0xFF5CF1FF), Color(0xFFFF4FD8)]),
              boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.7), blurRadius: 14)],
            ),
          ),
          const SizedBox(width: 10),
          const Text('POWERBOARD', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: SGColors.pulseGold.withOpacity(0.15), borderRadius: BorderRadius.circular(999), border: Border.all(color: SGColors.pulseGold.withOpacity(0.5))),
            child: const Text('SEASON 1', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: SGColors.pulseGold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isActive = _currentTab == index;
          return GestureDetector(
            onTap: () => setState(() => _currentTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: isActive ? const LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8)]) : null,
                color: isActive ? null : const Color(0xFF0D0F1A),
                border: isActive ? null : Border.all(color: const Color(0xFF23263A)),
              ),
              child: Text(_tabs[index], style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? const Color(0xFF050611) : SGColors.htmlMuted)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopThree() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodium(_rankings[1], 2, 80),
          const SizedBox(width: 8),
          _buildPodium(_rankings[0], 1, 100),
          const SizedBox(width: 8),
          _buildPodium(_rankings[2], 3, 65),
        ],
      ),
    );
  }

  Widget _buildPodium(Map<String, dynamic> user, int rank, double height) {
    Color color;
    switch (rank) {
      case 1: color = SGColors.pulseGold; break;
      case 2: color = Colors.grey; break;
      default: color = const Color(0xFFCD7F32);
    }
    return Expanded(
      child: Column(
        children: [
          Text(user['badge'], style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(user['user'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
          Text('${user['score']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withOpacity(0.8), color.withOpacity(0.3)]),
            ),
            child: Center(child: Text('#$rank', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 90),
      decoration: BoxDecoration(color: const Color(0xFF0D0F1A).withOpacity(0.9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF23263A))),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _rankings.length - 3,
        itemBuilder: (context, index) {
          final user = _rankings[index + 3];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color(0xFF23263A).withOpacity(0.5)))),
            child: Row(
              children: [
                SizedBox(width: 30, child: Text('#${user['rank']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SGColors.htmlMuted))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user['user'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)), Text('${user['entries']} entries', style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted))])),
                Text('${user['score']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5CF1FF))),
              ],
            ),
          );
        },
      ),
    );
  }
}
