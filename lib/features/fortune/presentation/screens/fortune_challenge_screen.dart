// lib/features/fortune/presentation/screens/fortune_challenge_screen.dart
// 2.11 Challenge - Zone detail with entries and leaderboard
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class FortuneChallengeScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic>? challengeData;

  const FortuneChallengeScreen({
    super.key,
    required this.challengeId,
    this.challengeData,
  });

  @override
  State<FortuneChallengeScreen> createState() => _FortuneChallengeScreenState();
}

class _FortuneChallengeScreenState extends State<FortuneChallengeScreen> {
  int _currentTab = 0;
  late Map<String, dynamic> _challenge;

  final List<Map<String, dynamic>> _entries = [
    {'creator': '@foodie.sam', 'aiScore': 9.35, 'humanScore': 8.85, 'rank': 1},
    {'creator': '@street.eats', 'aiScore': 9.10, 'humanScore': 8.70, 'rank': 2},
    {'creator': '@local.lens', 'aiScore': 8.90, 'humanScore': 8.55, 'rank': 3},
    {'creator': '@event.hunter', 'aiScore': 8.65, 'humanScore': 8.30, 'rank': 4},
  ];

  @override
  void initState() {
    super.initState();
    _challenge = widget.challengeData ?? {
      'id': widget.challengeId,
      'icon': '🍜',
      'title': 'Food Grid Hunt',
      'desc': 'Capture the moment of the first bite.',
      'zone': 'Zone: Food Street',
      'type': 'both',
      'tags': ['Photo / Short Video'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  children: [
                    _buildChallengeCard(),
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
            onTap: () => context.go('/fortune'),
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
                  Text('Fortune', style: TextStyle(fontSize: 13, color: Color(0xFFA7B0C6))),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB84D).withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFFB84D).withOpacity(0.5)),
            ),
            child: Text(_challenge['zone'] ?? 'Zone', style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: Color(0xFFFFB84D))),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          colors: [const Color(0xFFFFB84D).withOpacity(0.15), const Color(0xFF0C0F1F), const Color(0xFF070814)],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(color: const Color(0xFFFFB84D).withOpacity(0.3)),
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
                  gradient: const LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8)]),
                ),
                child: Center(child: Text(_challenge['icon'] ?? '🍜', style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_challenge['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTypeBadge(_challenge['type'] ?? 'both'),
                        const SizedBox(width: 6),
                        Text('Ends in 3 days', style: TextStyle(fontSize: 11, color: const Color(0xFFFFB84D))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_challenge['desc'] ?? '', style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted, height: 1.5)),
          const SizedBox(height: 12),
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
                _buildStatItem('${_entries.length * 28}', 'Entries'),
                _buildStatItem('5.8K', 'Views'),
                _buildStatItem('₹10,000', 'Prize Pool'),
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
      onTap: () => context.go('/fortune/live/${widget.challengeId}', extra: _challenge),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8)]),
          boxShadow: [BoxShadow(color: const Color(0xFFFFB84D).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: Color(0xFF050611), size: 20),
            SizedBox(width: 8),
            Text('JOIN CHALLENGE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Color(0xFF050611))),
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
          gradient: isActive ? const LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8)]) : null,
          color: isActive ? null : const Color(0xFF070814).withOpacity(0.7),
          border: isActive ? null : Border.all(color: const Color(0xFF23263A)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? const Color(0xFF050611) : const Color(0xFFA7B0C6),
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
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: RadialGradient(
              center: Alignment.topCenter,
              colors: [const Color(0xFFFFB84D).withOpacity(0.2), const Color(0xFF070814)],
            ),
            border: Border.all(color: const Color(0xFFFFB84D).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0D0F1A),
                  ),
                  child: Stack(
                    children: [
                      const Center(child: Text('🍜', style: TextStyle(fontSize: 32))),
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
                    ],
                  ),
                ),
              ),
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
        );
      },
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F1A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF23263A)),
      ),
      child: Column(
        children: List.generate(_entries.length, (index) {
          final entry = _entries[index];
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
                    Text(((entry['aiScore'] + (entry['humanScore'] ?? 0)) / 2 * 10).toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFB84D))),
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
    final rules = ['Original content only', 'Max 60 second video', 'Family-friendly content', 'One entry per challenge', 'Must be captured at event'];
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
          const Text('Challenge Rules', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          ...rules.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFB84D).withOpacity(0.2)),
                  child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontSize: 10, color: Color(0xFFFFB84D)))),
                ),
                const SizedBox(width: 10),
                Text(e.value, style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
