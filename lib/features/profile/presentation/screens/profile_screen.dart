// lib/features/profile/presentation/screens/profile_screen.dart
// 5. Profile - My Uploads, Performance, Settings
import 'package:flutter/material.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentTab = 0;
  final List<String> _tabs = ['My Uploads', 'Performance', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [const Color(0xFF111827).withOpacity(0.8), SGColors.carbonBlack],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileCard(),
              _buildStats(),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 12),
              Expanded(
                child: _currentTab == 0 ? _buildUploadsGrid() : (_currentTab == 1 ? _buildPerformance() : _buildSettings()),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 3),
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
          const Text('PROFILE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: Colors.white)),
          const Spacer(),
          Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.7), size: 20),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF5CF1FF)]),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
            ),
            child: const Center(child: Text('👤', style: TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('@your.handle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Creator since Jan 2025', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8)]), borderRadius: BorderRadius.circular(999)),
                child: const Text('RISING CREATOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Color(0xFF050611))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF0D0F1A).withOpacity(0.9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF23263A))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('12', 'Uploads'),
          Container(width: 1, height: 40, color: const Color(0xFF23263A)),
          _buildStatItem('8.9', 'Avg Score'),
          Container(width: 1, height: 40, color: const Color(0xFF23263A)),
          _buildStatItem('#24', 'Rank'),
          Container(width: 1, height: 40, color: const Color(0xFF23263A)),
          _buildStatItem('1.2K', 'Views'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: SGColors.htmlMuted)),
      ],
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isActive = _currentTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = index),
              child: Container(
                margin: EdgeInsets.only(right: index < _tabs.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: isActive ? const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF5CF1FF)]) : null,
                  color: isActive ? null : const Color(0xFF0D0F1A),
                  border: isActive ? null : Border.all(color: const Color(0xFF23263A)),
                ),
                child: Text(_tabs[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? Colors.white : SGColors.htmlMuted)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUploadsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFF0D0F1A), border: Border.all(color: const Color(0xFF23263A))),
          child: Stack(
            children: [
              Center(child: Text(['🍜', '👗', '🎬', '💃', '📸', '🌿', '🎡', '🎓', '🎙️'][index % 9], style: const TextStyle(fontSize: 28))),
              Positioned(
                bottom: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                  child: Text('${8.5 + index * 0.1}', style: const TextStyle(fontSize: 9, color: SGColors.pulseGold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformance() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
      children: [
        _buildPerformanceCard('Fortune', 5, 9.1, const Color(0xFFFFB84D)),
        _buildPerformanceCard('Fanverse', 4, 8.9, const Color(0xFFFF4FD8)),
        _buildPerformanceCard('GridVoice', 3, 8.7, const Color(0xFF5CFFB1)),
      ],
    );
  }

  Widget _buildPerformanceCard(String grid, int entries, double avgScore, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF0D0F1A).withOpacity(0.9), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.2)), child: Center(child: Text(grid[0], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(grid, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)), Text('$entries entries', style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('$avgScore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), const Text('Avg Score', style: TextStyle(fontSize: 10, color: SGColors.htmlMuted))]),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    final settings = [
      {'icon': Icons.person_outline, 'title': 'Edit Profile', 'subtitle': 'Name, bio, photo'},
      {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'subtitle': 'Push, email alerts'},
      {'icon': Icons.lock_outline, 'title': 'Privacy', 'subtitle': 'Account visibility'},
      {'icon': Icons.help_outline, 'title': 'Help & Support', 'subtitle': 'FAQs, contact us'},
      {'icon': Icons.info_outline, 'title': 'About', 'subtitle': 'Version 1.0.0'},
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
      children: settings.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF0D0F1A).withOpacity(0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF23263A))),
        child: Row(
          children: [
            Icon(s['icon'] as IconData, color: SGColors.htmlMuted, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)), Text(s['subtitle'] as String, style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted))])),
            const Icon(Icons.chevron_right, color: SGColors.htmlMuted, size: 20),
          ],
        ),
      )).toList(),
    );
  }
}
