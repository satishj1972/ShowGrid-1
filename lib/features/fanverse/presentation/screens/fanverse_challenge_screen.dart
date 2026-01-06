// lib/features/fanverse/presentation/screens/fanverse_challenge_screen.dart
// 2.21 Challenge - Episode detail with entries and leaderboard
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class FanverseChallengeScreen extends StatefulWidget {
  final String episodeId;
  final Map<String, dynamic>? episodeData;

  const FanverseChallengeScreen({
    super.key,
    required this.episodeId,
    this.episodeData,
  });

  @override
  State<FanverseChallengeScreen> createState() => _FanverseChallengeScreenState();
}

class _FanverseChallengeScreenState extends State<FanverseChallengeScreen> {
  int _currentTab = 0;
  late Map<String, dynamic> _episode;

  final List<Map<String, dynamic>> _entries = [
    {'creator': '@magenta.fan', 'aiScore': 9.45, 'humanScore': 8.90, 'rank': 1},
    {'creator': '@pose.queen', 'aiScore': 9.20, 'humanScore': 8.75, 'rank': 2},
    {'creator': '@film.lover', 'aiScore': 8.95, 'humanScore': 8.60, 'rank': 3},
    {'creator': '@style.icon', 'aiScore': 8.70, 'humanScore': 8.40, 'rank': 4},
  ];

  @override
  void initState() {
    super.initState();
    _episode = widget.episodeData ?? {
      'id': widget.episodeId,
      'icon': '🎞️',
      'title': 'Poster Pose Remix',
      'desc': 'Recreate the iconic Magenta poster pose — same framing or your own twist.',
      'episode': 'Episode 01',
      'type': 'photo',
      'tags': ['Photo', 'Solo / Duo'],
    };
  }

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
              _buildTopBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  children: [
                    _buildEpisodeCard(),
                    const SizedBox(height: 12),
                    _buildJoinButton(),
                    const SizedBox(height: 16),
                    _buildTabs(),
                    const SizedBox(height: 12),
                    if (_currentTab == 0) _buildEntriesGrid(),
                    if (_currentTab == 1) _buildLeaderboard(),
                    if (_currentTab == 2) _buildRulesSection(),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/fanverse'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0F1A).withOpacity(0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF23263A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back, color: Color(0xFFA7B0C6), size: 16),
                  SizedBox(width: 6),
                  Text('Fanverse', style: TextStyle(fontSize: 13, color: Color(0xFFA7B0C6))),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4FD8).withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFF4FD8).withOpacity(0.5)),
            ),
            child: Text(_episode['episode'] ?? 'Episode', style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: Color(0xFFFF4FD8))),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          colors: [const Color(0xFFFF4FD8).withOpacity(0.15), const Color(0xFF0C0F1F), const Color(0xFF070814)],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(color: const Color(0xFFFF4FD8).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]),
                ),
                child: Center(child: Text(_episode['icon'] ?? '🎞️', style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_episode['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTypeBadge(_episode['type'] ?? 'photo'),
                        const SizedBox(width: 6),
                        Text('Ends in 5 days', style: TextStyle(fontSize: 11, color: const Color(0xFF9B7DFF))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_episode['desc'] ?? '', style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted, height: 1.5)),
          const SizedBox(height: 12),
          // Stats row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF070814).withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('${_entries.length * 24}', 'Entries'),
                _buildStatItem('4.2K', 'Views'),
                _buildStatItem('₹5,000', 'Prize Pool'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    IconData icon;
    String label;
    switch (type) {
      case 'video':
        icon = Icons.videocam;
        label = 'Video';
        break;
      case 'both':
        icon = Icons.photo_camera;
        label = 'Photo/Video';
        break;
      default:
        icon = Icons.camera_alt;
        label = 'Photo';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF5CF1FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF5CF1FF).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF5CF1FF)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF5CF1FF))),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: SGColors.htmlMuted)),
      ],
    );
  }

  Widget _buildJoinButton() {
    return GestureDetector(
      onTap: () => context.go('/fanverse/live/${widget.episodeId}', extra: _episode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]),
          boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('JOIN & CREATE ENTRY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _buildTab('Entries', 0)),
        const SizedBox(width: 6),
        Expanded(child: _buildTab('Leaderboard', 1)),
        const SizedBox(width: 6),
        Expanded(child: _buildTab('Rules', 2)),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: isActive ? const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]) : null,
          color: isActive ? null : const Color(0xFF070814).withOpacity(0.7),
          border: isActive ? null : Border.all(color: const Color(0xFF23263A)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.white : const Color(0xFFA7B0C6),
          ),
        ),
      ),
    );
  }

  Widget _buildEntriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return GestureDetector(
          onTap: () => context.go('/rate', extra: {'entryId': entry['creator']}),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(
                center: Alignment.topCenter,
                colors: [const Color(0xFFFF4FD8).withOpacity(0.2), const Color(0xFF070814)],
              ),
              border: Border.all(color: const Color(0xFFFF4FD8).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                // Media preview
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF0D0F1A),
                    ),
                    child: Stack(
                      children: [
                        const Center(child: Text('🎬', style: TextStyle(fontSize: 32))),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('AI ${entry['aiScore']}', style: const TextStyle(fontSize: 9, color: SGColors.pulseGold)),
                          ),
                        ),
                        if (entry['rank'] <= 3)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: entry['rank'] == 1 ? SGColors.pulseGold : (entry['rank'] == 2 ? Colors.grey : const Color(0xFFCD7F32)),
                              ),
                              child: Text('${entry['rank']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Creator info
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Column(
                    children: [
                      Text(entry['creator'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 12, color: SGColors.pulseGold),
                          const SizedBox(width: 2),
                          Text('${entry['humanScore'] ?? '--'}', style: const TextStyle(fontSize: 10, color: SGColors.htmlMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboard() {
    final sortedEntries = List<Map<String, dynamic>>.from(_entries)
      ..sort((a, b) => (b['aiScore'] as double).compareTo(a['aiScore'] as double));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F1A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF23263A)),
      ),
      child: Column(
        children: List.generate(sortedEntries.length, (index) {
          final entry = sortedEntries[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: const Color(0xFF23263A).withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0 ? SGColors.pulseGold : (index == 1 ? Colors.grey : (index == 2 ? const Color(0xFFCD7F32) : const Color(0xFF23263A))),
                  ),
                  child: Center(
                    child: Text('${index + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: index < 3 ? Colors.black : Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry['creator'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('AI: ${entry['aiScore']} · Human: ${entry['humanScore'] ?? '--'}', style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(((entry['aiScore'] + (entry['humanScore'] ?? 0)) / 2 * 10).toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5CF1FF))),
                    const Text('Final', style: TextStyle(fontSize: 9, color: SGColors.htmlMuted)),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRulesSection() {
    final rules = [
      'Create original content inspired by the episode theme',
      'No copied or AI-generated content allowed',
      'Maximum video length: 60 seconds',
      'Keep it family-friendly',
      'One entry per user per episode',
      'Entries judged on creativity, execution, and theme fit',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F1A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF23263A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Episode Rules', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          ...rules.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF4FD8).withOpacity(0.2),
                  ),
                  child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontSize: 10, color: Color(0xFFFF4FD8)))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
