// lib/features/gridvoice/presentation/screens/gridvoice_challenge_screen.dart
// 2.31 Challenge - Chapter detail with entries and leaderboard
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class GridVoiceChallengeScreen extends StatefulWidget {
  final String chapterId;
  final Map<String, dynamic>? chapterData;

  const GridVoiceChallengeScreen({
    super.key,
    required this.chapterId,
    this.chapterData,
  });

  @override
  State<GridVoiceChallengeScreen> createState() => _GridVoiceChallengeScreenState();
}

class _GridVoiceChallengeScreenState extends State<GridVoiceChallengeScreen> {
  int _currentTab = 0;
  late Map<String, dynamic> _chapter;

  final List<Map<String, dynamic>> _entries = [
    {'creator': '@tn.stories', 'aiScore': 9.30, 'humanScore': 9.00, 'hasAudio': true, 'rank': 1},
    {'creator': '@village.voice', 'aiScore': 9.10, 'humanScore': 8.80, 'hasAudio': true, 'rank': 2},
    {'creator': '@street.lens', 'aiScore': 8.85, 'humanScore': 8.60, 'hasAudio': false, 'rank': 3},
    {'creator': '@local.hero', 'aiScore': 8.60, 'humanScore': 8.40, 'hasAudio': true, 'rank': 4},
  ];

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapterData ?? {
      'id': widget.chapterId,
      'icon': '📸',
      'title': 'TN Through You',
      'desc': 'Show the Tamil Nadu you see every day.',
      'chapter': 'Chapter 01',
      'type': 'both',
      'tags': ['Photo / Video', 'Everyday Life'],
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
            colors: [Color(0xFF1F2F3F), Color(0xFF020214), Color(0xFF01000C)],
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
                    _buildChapterCard(),
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
            onTap: () => context.go('/gridvoice'),
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
                  Text('GridVoice', style: TextStyle(fontSize: 13, color: Color(0xFFA7B0C6))),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF5CFFB1).withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.5)),
            ),
            child: Text(_chapter['chapter'] ?? 'Chapter', style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: Color(0xFF5CFFB1))),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          colors: [const Color(0xFF5CFFB1).withOpacity(0.15), const Color(0xFF0C0F1F), const Color(0xFF070814)],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.3)),
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
                  gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
                ),
                child: Center(child: Text(_chapter['icon'] ?? '📸', style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_chapter['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTypeBadge(_chapter['type'] ?? 'both'),
                        const SizedBox(width: 6),
                        _buildAudioBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_chapter['desc'] ?? '', style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted, height: 1.5)),
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
                _buildStatItem('${_entries.length * 32}', 'Stories'),
                _buildStatItem('6.1K', 'Listens'),
                _buildStatItem('Season 1', 'Active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF5CFFB1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.photo_camera, size: 12, color: Color(0xFF5CFFB1)),
          SizedBox(width: 4),
          Text('Photo/Video', style: TextStyle(fontSize: 10, color: Color(0xFF5CFFB1))),
        ],
      ),
    );
  }

  Widget _buildAudioBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF5CA8FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF5CA8FF).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.mic, size: 12, color: Color(0xFF5CA8FF)),
          SizedBox(width: 4),
          Text('Voice', style: TextStyle(fontSize: 10, color: Color(0xFF5CA8FF))),
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
      onTap: () => context.go('/gridvoice/live/${widget.chapterId}', extra: _chapter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
          boxShadow: [BoxShadow(color: const Color(0xFF5CFFB1).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: Color(0xFF050611), size: 20),
            SizedBox(width: 8),
            Text('SHARE YOUR STORY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Color(0xFF050611))),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _buildTab('Stories', 0)),
        const SizedBox(width: 6),
        Expanded(child: _buildTab('Leaderboard', 1)),
        const SizedBox(width: 6),
        Expanded(child: _buildTab('Guidelines', 2)),
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
          gradient: isActive ? const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]) : null,
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
        return GestureDetector(
          onTap: () => context.go('/rate', extra: {'entryId': entry['creator']}),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(
                center: Alignment.topCenter,
                colors: [const Color(0xFF5CFFB1).withOpacity(0.2), const Color(0xFF070814)],
              ),
              border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.3)),
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
                        const Center(child: Text('🌿', style: TextStyle(fontSize: 32))),
                        // Audio indicator
                        if (entry['hasAudio'] == true)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5CA8FF).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.mic, color: Colors.white, size: 10),
                                  SizedBox(width: 2),
                                  Text('Voice', style: TextStyle(fontSize: 8, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        // AI Score
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
          final finalScore = ((entry['aiScore'] ?? 0) * 0.4 + (entry['humanScore'] ?? 0) * 0.6) * 10;
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
                      Row(
                        children: [
                          Text(entry['creator'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                          if (entry['hasAudio'] == true) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.mic, size: 12, color: Color(0xFF5CA8FF)),
                          ],
                        ],
                      ),
                      Text('AI: ${entry['aiScore']} · Community: ${entry['humanScore'] ?? '--'}', style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(finalScore.toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5CFFB1))),
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
    final guidelines = [
      'Share authentic stories from Tamil Nadu',
      'Voice recordings must be in Tamil, English, or both',
      'Keep content respectful and non-political',
      'No hate speech or discriminatory content',
      'Original content only - no reposts',
      'Maximum video length: 90 seconds',
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
          const Text('Story Guidelines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          ...guidelines.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF5CFFB1).withOpacity(0.2),
                  ),
                  child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontSize: 10, color: Color(0xFF5CFFB1)))),
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
