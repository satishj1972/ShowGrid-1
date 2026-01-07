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
            const Text(
              'Choose Entry Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'For: ${_data?['title'] ?? 'Challenge'}',
              style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted),
            ),
            const SizedBox(height: 24),
            
            if (mediaType.contains('photo'))
              _buildOptionTile(
                icon: Icons.camera_alt,
                title: 'Photo',
                subtitle: 'Capture or upload a photo',
                color: SGColors.htmlViolet,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/fortune/photo/${widget.challengeId}', extra: _data);
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
                  context.push('/fortune/video/${widget.challengeId}', extra: _data);
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
                  const SizedBox(height: 2),
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
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Challenge Info
              _buildChallengeInfo(),
              
              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: SGColors.htmlGlass,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: SGColors.htmlViolet,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: SGColors.htmlMuted,
                  tabs: const [
                    Tab(text: 'Entries'),
                    Tab(text: 'Leaderboard'),
                    Tab(text: 'Rules'),
                  ],
                ),
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEntriesTab(),
                    _buildLeaderboardTab(),
                    _buildRulesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Participate button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: SGColors.carbonBlack,
          border: Border(top: BorderSide(color: SGColors.borderSubtle)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _showParticipateOptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: SGColors.htmlViolet,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 22),
                SizedBox(width: 8),
                Text('Participate Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _data?['title'] ?? 'Challenge',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: SGColors.htmlGreen.withOpacity(0.2),
            ),
            child: const Text('LIVE', style: TextStyle(fontSize: 11, color: SGColors.htmlGreen, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeInfo() {
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
          Text(
            _data?['description'] ?? 'No description',
            style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.people, '${_data?['entriesCount'] ?? 0} entries'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.emoji_events, _data?['prizePool'] ?? ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: SGColors.htmlViolet.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: SGColors.htmlViolet),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: SGColors.htmlViolet)),
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 60, color: SGColors.htmlMuted),
                SizedBox(height: 16),
                Text('No entries yet', style: TextStyle(fontSize: 16, color: SGColors.htmlMuted)),
                SizedBox(height: 8),
                Text('Be the first to participate!', style: TextStyle(fontSize: 14, color: SGColors.htmlMuted)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index].data() as Map<String, dynamic>;
            return _buildEntryCard(entry);
          },
        );
      },
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final score = entry['aiScore']?['overallScore'] ?? 0.0;
    final grade = entry['aiScore']?['grade'] ?? '-';
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SGColors.borderSubtle),
        image: entry['mediaUrl'] != null
            ? DecorationImage(
                image: NetworkImage(entry['thumbnailUrl'] ?? entry['mediaUrl']),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ),
          
          // Score badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: SGColors.htmlViolet,
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          
          // User info
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: SGColors.htmlViolet,
                  child: Text(
                    (entry['userName'] ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry['userName'] ?? 'Anonymous',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Video icon
          if (entry['mediaType'] == 'video')
            const Positioned(
              top: 8,
              left: 8,
              child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 24),
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
          return const Center(
            child: Text('No rankings yet', style: TextStyle(color: SGColors.htmlMuted)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index].data() as Map<String, dynamic>;
            return _buildLeaderboardItem(index + 1, entry);
          },
        );
      },
    );
  }

  Widget _buildLeaderboardItem(int rank, Map<String, dynamic> entry) {
    final score = entry['aiScore']?['overallScore'] ?? 0.0;
    
    Color rankColor = SGColors.htmlMuted;
    IconData? medalIcon;
    if (rank == 1) { rankColor = SGColors.htmlGold; medalIcon = Icons.emoji_events; }
    if (rank == 2) { rankColor = Colors.grey[300]!; medalIcon = Icons.emoji_events; }
    if (rank == 3) { rankColor = Colors.orange[300]!; medalIcon = Icons.emoji_events; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: SGColors.htmlGlass,
        border: Border.all(color: rank <= 3 ? rankColor.withOpacity(0.3) : SGColors.borderSubtle),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: medalIcon != null
                ? Icon(medalIcon, color: rankColor, size: 28)
                : Text('#$rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: rankColor)),
          ),
          
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: SGColors.htmlViolet,
            child: Text(
              (entry['userName'] ?? 'A')[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Text(
              entry['userName'] ?? 'Anonymous',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: SGColors.htmlViolet.withOpacity(0.2),
            ),
            child: Text(
              score.toStringAsFixed(1),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SGColors.htmlViolet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRuleSection('How to Participate', [
            'Capture a photo or video related to the challenge theme',
            'Make sure your content is original and creative',
            'Submit before the deadline',
          ]),
          const SizedBox(height: 20),
          _buildRuleSection('Scoring Criteria', [
            'Creativity (20%) - How original is your submission?',
            'Quality (20%) - Technical quality and composition',
            'Relevance (20%) - How well does it match the theme?',
            'Impact (20%) - Visual/emotional impact',
            'Effort (20%) - Apparent effort put into it',
          ]),
          const SizedBox(height: 20),
          _buildRuleSection('Guidelines', [
            'No offensive or inappropriate content',
            'Must be your own original work',
            'One entry per challenge',
            'Winners announced after challenge ends',
          ]),
        ],
      ),
    );
  }

  Widget _buildRuleSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: SGColors.htmlGlass,
        border: Border.all(color: SGColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, size: 16, color: SGColors.htmlGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item, style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted, height: 1.4)),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
