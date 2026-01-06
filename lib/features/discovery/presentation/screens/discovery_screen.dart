// lib/features/discovery/presentation/screens/discovery_screen.dart
// 3. Discovery - Feed of all images and videos
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  int _currentFilter = 0;
  final List<String> _filters = ['All', 'Fortune', 'Fanverse', 'GridVoice', 'Trending'];

  final List<Map<String, dynamic>> _entries = [
    {'creator': '@foodie.sam', 'type': 'fortune', 'aiScore': 9.35, 'likes': 234, 'icon': '🍜'},
    {'creator': '@magenta.fan', 'type': 'fanverse', 'aiScore': 9.45, 'likes': 567, 'icon': '🎬'},
    {'creator': '@tn.stories', 'type': 'gridvoice', 'aiScore': 9.30, 'likes': 189, 'icon': '🌿'},
    {'creator': '@street.style', 'type': 'fortune', 'aiScore': 9.10, 'likes': 412, 'icon': '👗'},
    {'creator': '@pose.queen', 'type': 'fanverse', 'aiScore': 9.20, 'likes': 389, 'icon': '💃'},
    {'creator': '@village.voice', 'type': 'gridvoice', 'aiScore': 9.10, 'likes': 256, 'icon': '📸'},
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
              _buildFilters(),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) => _buildEntryCard(_entries[index]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 1),
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
          const Text('DISCOVER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: Colors.white)),
          const Spacer(),
          Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isActive = _currentFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _currentFilter = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: isActive ? const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF5CF1FF)]) : null,
                color: isActive ? null : const Color(0xFF0D0F1A),
                border: isActive ? null : Border.all(color: const Color(0xFF23263A)),
              ),
              child: Text(_filters[index], style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? Colors.white : SGColors.htmlMuted)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    Color typeColor;
    switch (entry['type']) {
      case 'fortune': typeColor = const Color(0xFFFFB84D); break;
      case 'fanverse': typeColor = const Color(0xFFFF4FD8); break;
      case 'gridvoice': typeColor = const Color(0xFF5CFFB1); break;
      default: typeColor = const Color(0xFF5CF1FF);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0D0F1A),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: typeColor.withOpacity(0.1),
              child: Stack(
                children: [
                  Center(child: Text(entry['icon'], style: const TextStyle(fontSize: 48))),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: typeColor.withOpacity(0.9), borderRadius: BorderRadius.circular(999)),
                      child: Text(entry['type'].toString().toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black)),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(999)),
                      child: Text('AI ${entry['aiScore']}', style: const TextStyle(fontSize: 9, color: SGColors.pulseGold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry['creator'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                    Row(children: [const Icon(Icons.favorite, size: 12, color: Color(0xFFFF4FD8)), const SizedBox(width: 4), Text('${entry['likes']}', style: const TextStyle(fontSize: 10, color: SGColors.htmlMuted))]),
                  ],
                ),
                const Icon(Icons.more_vert, color: SGColors.htmlMuted, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
