// lib/features/fortune/presentation/screens/challenge_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/services/entry_service.dart';

class ChallengeScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic>? challengeData;
  final String gridType;

  const ChallengeScreen({
    super.key,
    required this.challengeId,
    this.challengeData,
    this.gridType = 'fortune',
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _data = widget.challengeData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showParticipateOptions() {
    final mediaType = _data?['mediaType'] ?? 'photo_video';
    final isGridVoice = widget.gridType == 'gridvoice';
    
    if (isGridVoice) {
      // GridVoice only has audio
      context.push('/gridvoice/record/${widget.challengeId}', extra: _data);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: SGColors.carbonBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Entry Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Text('For: ${_data?['title'] ?? 'Challenge'}', style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted)),
            const SizedBox(height: 24),
            
            if (mediaType.contains('photo'))
              _buildOptionTile(
                icon: Icons.camera_alt,
                title: 'Photo',
                subtitle: 'Capture or upload a photo',
                color: SGColors.htmlViolet,
                onTap: () {
                  Navigator.pop(context);
                  final route = widget.gridType == 'fanverse' ? '/fanverse/photo' : '/fortune/photo';
                  context.push('$route/${widget.challengeId}', extra: _data);
                },
              ),
            
            if (mediaType.contains('video'))
              _buildOptionTile(
                icon: Icons.videocam,
                title: 'Video',
                subtitle: 'Record up to ${_data?['maxDuration'] ?? 60}s video',
                color: SGColors.htmlPink,
                onTap: () {
                  Navigator.pop(context);
                  final route = widget.gridType == 'fanverse' ? '/fanverse/video' : '/fortune/video';
                  context.push('$route/${widget.challengeId}', extra: _data);
                },
              ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          color: color.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.2)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
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

  @override
  Widget build(BuildContext context) {
    final isGridVoice = widget.gridType == 'gridvoice';
    final accentColor = isGridVoice ? SGColors.htmlGreen : 
                        widget.gridType == 'fanverse' ? SGColors.htmlPink : SGColors.htmlViolet;

    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(accentColor),
              _buildChallengeInfo(accentColor),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: SGColors.htmlGlass),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(borderRadius: BorderRadius.circular(12), color: accentColor),
                  labelColor: Colors.white,
                  unselectedLabelColor: SGColors.htmlMuted,
                  tabs: [
                    Tab(text: isGridVoice ? 'Stories' : 'Entries'),
                    const Tab(text: 'Leaderboard'),
                    Tab(text: isGridVoice ? 'Guidelines' : 'Rules'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildEntriesTab(), _buildLeaderboardTab(), _buildRulesTab()],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: SGColors.carbonBlack, border: Border(top: BorderSide(color: SGColors.borderSubtle))),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _showParticipateOptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isGridVoice ? Icons.mic : Icons.add_circle_outline, size: 22),
                const SizedBox(width: 8),
                Text(isGridVoice ? 'Record Story' : 'Participate Now', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_data?['title'] ?? 'Challenge', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: accentColor.withOpacity(0.2)),
            child: Text('LIVE', style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeInfo(Color accentColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: SGColors.htmlGlass,
        border: Border.all(color: SGColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_data?['description'] ?? 'No description', style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.people, '${_data?['entriesCount'] ?? 0} entries', accentColor),
              const SizedBox(width: 12),
              if (_data?['prizePool'] != null) _buildInfoChip(Icons.emoji_events, _data!['prizePool'], accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: color.withOpacity(0.1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildEntriesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: EntryService.getEntriesForChallenge(widget.challengeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SGColors.htmlViolet));
        }
        final entries = snapshot.data?.docs ?? [];
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.gridType == 'gridvoice' ? Icons.mic_off : Icons.inbox_outlined, size: 60, color: SGColors.htmlMuted),
                const SizedBox(height: 16),
                const Text('No entries yet', style: TextStyle(fontSize: 16, color: SGColors.htmlMuted)),
                const Text('Be the first to participate!', style: TextStyle(fontSize: 14, color: SGColors.htmlMuted)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index].data() as Map<String, dynamic>;
            return _buildEntryItem(entry);
          },
        );
      },
    );
  }

  Widget _buildEntryItem(Map<String, dynamic> entry) {
    final score = entry['aiScore']?['overallScore'] ?? 0.0;
    final userName = entry['userName'] ?? 'Anonymous';
    final isAudio = entry['mediaType'] == 'audio';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: SGColors.htmlGlass,
        border: Border.all(color: SGColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: SGColors.htmlGreen.withOpacity(0.2),
              image: !isAudio && entry['thumbnailUrl'] != null
                  ? DecorationImage(image: NetworkImage(entry['thumbnailUrl']), fit: BoxFit.cover)
                  : null,
            ),
            child: isAudio ? const Icon(Icons.headphones, color: SGColors.htmlGreen) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(isAudio ? 'Audio Story' : entry['mediaType'] ?? 'Photo', style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: SGColors.htmlViolet.withOpacity(0.2)),
            child: Text(score.toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SGColors.htmlViolet)),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: EntryService.getLeaderboard(challengeId: widget.challengeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SGColors.htmlGold));
        }
        final entries = snapshot.data?.docs ?? [];
        if (entries.isEmpty) {
          return const Center(child: Text('No rankings yet', style: TextStyle(color: SGColors.htmlMuted)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index].data() as Map<String, dynamic>;
            final score = entry['finalScore'] ?? entry['aiScore']?['overallScore'] ?? 0.0;
            final userName = entry['userName'] ?? 'Anonymous';
            
            Color rankColor = SGColors.htmlMuted;
            if (index == 0) rankColor = SGColors.htmlGold;
            if (index == 1) rankColor = Colors.grey;
            if (index == 2) rankColor = Colors.orange;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: SGColors.htmlGlass,
                border: Border.all(color: index < 3 ? rankColor.withOpacity(0.3) : SGColors.borderSubtle),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: index < 3
                        ? Icon(Icons.emoji_events, color: rankColor, size: 24)
                        : Text('#${index + 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: rankColor)),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(radius: 18, backgroundColor: SGColors.htmlViolet, child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(userName, style: const TextStyle(fontSize: 14, color: Colors.white))),
                  Text(score.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SGColors.htmlViolet)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRulesTab() {
    final isGridVoice = widget.gridType == 'gridvoice';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRuleSection('How to Participate', isGridVoice
              ? ['Record your voice story (up to 3 minutes)', 'Speak clearly and with emotion', 'Tell an engaging story']
              : ['Capture a photo or video', 'Make sure content is original', 'Submit before deadline']),
          const SizedBox(height: 20),
          _buildRuleSection('Scoring Criteria', [
            'Creativity (20%)', 'Quality (20%)', 'Relevance (20%)', 'Impact (20%)', 'Effort (20%)',
          ]),
        ],
      ),
    );
  }

  Widget _buildRuleSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: SGColors.htmlGlass, border: Border.all(color: SGColors.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: SGColors.htmlGreen),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
