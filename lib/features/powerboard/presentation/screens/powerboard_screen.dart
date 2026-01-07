// lib/features/powerboard/presentation/screens/powerboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class PowerboardScreen extends StatefulWidget {
  const PowerboardScreen({super.key});

  @override
  State<PowerboardScreen> createState() => _PowerboardScreenState();
}

class _PowerboardScreenState extends State<PowerboardScreen> {
  String _selectedFilter = 'all';
  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'Global'},
    {'id': 'fortune', 'label': 'Fortune'},
    {'id': 'fanverse', 'label': 'Fanverse'},
    {'id': 'gridvoice', 'label': 'GridVoice'},
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
              Expanded(child: _buildLeaderboard()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
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
          const SizedBox(width: 10),
          const Text(
            'POWERBOARD',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white),
          ),
          const Spacer(),
          const Icon(Icons.emoji_events, color: SGColors.htmlGold, size: 28),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter['id'];
          
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter['id']),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? SGColors.htmlViolet : SGColors.htmlGlass,
                border: Border.all(color: isSelected ? SGColors.htmlViolet : SGColors.borderSubtle),
              ),
              child: Center(
                child: Text(
                  filter['label'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : SGColors.htmlMuted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaderboard() {
    Query query = FirebaseFirestore.instance
        .collection('entries')
        .where('status', isEqualTo: 'scored')
        .orderBy('finalScore', descending: true)
        .limit(50);

    if (_selectedFilter != 'all') {
      query = query.where('gridType', isEqualTo: _selectedFilter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SGColors.htmlGold));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }

        final entries = snapshot.data?.docs ?? [];

        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard_outlined, size: 60, color: SGColors.htmlMuted),
                SizedBox(height: 16),
                Text('No rankings yet', style: TextStyle(fontSize: 16, color: SGColors.htmlMuted)),
                SizedBox(height: 8),
                Text('Be the first to submit!', style: TextStyle(fontSize: 14, color: SGColors.htmlMuted)),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Top 3 Podium
            if (entries.length >= 3)
              SliverToBoxAdapter(child: _buildPodium(entries.take(3).toList())),
            
            // Rest of the list
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final actualIndex = entries.length >= 3 ? index + 3 : index;
                    if (actualIndex >= entries.length) return null;
                    
                    final entry = entries[actualIndex].data() as Map<String, dynamic>;
                    return _buildRankItem(actualIndex + 1, entry);
                  },
                  childCount: entries.length >= 3 ? entries.length - 3 : entries.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPodium(List<QueryDocumentSnapshot> top3) {
    final first = top3[0].data() as Map<String, dynamic>;
    final second = top3[1].data() as Map<String, dynamic>;
    final third = top3[2].data() as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _buildPodiumItem(2, second, 100, Colors.grey[400]!),
          const SizedBox(width: 8),
          // 1st place
          _buildPodiumItem(1, first, 130, SGColors.htmlGold),
          const SizedBox(width: 8),
          // 3rd place
          _buildPodiumItem(3, third, 80, Colors.orange[300]!),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(int rank, Map<String, dynamic> entry, double height, Color color) {
    final score = entry['finalScore'] ?? entry['aiScore']?['overallScore'] ?? 0.0;
    final userName = entry['userName'] ?? 'Anonymous';

    return Column(
      children: [
        // Avatar
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: rank == 1 ? 70 : 56,
              height: rank == 1 ? 70 : 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                image: entry['userPhoto'] != null
                    ? DecorationImage(image: NetworkImage(entry['userPhoto']), fit: BoxFit.cover)
                    : null,
                color: SGColors.htmlGlass,
              ),
              child: entry['userPhoto'] == null
                  ? Center(
                      child: Text(
                        userName[0].toUpperCase(),
                        style: TextStyle(fontSize: rank == 1 ? 24 : 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    )
                  : null,
            ),
            // Medal
            Positioned(
              bottom: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Text(
                  rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Name
        SizedBox(
          width: 80,
          child: Text(
            userName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        // Score
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 8),
        // Podium block
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(int rank, Map<String, dynamic> entry) {
    final score = entry['finalScore'] ?? entry['aiScore']?['overallScore'] ?? 0.0;
    final userName = entry['userName'] ?? 'Anonymous';
    final gridType = entry['gridType'] ?? 'fortune';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: SGColors.htmlGlass,
        border: Border.all(color: SGColors.borderSubtle),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: Text(
              '#$rank',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SGColors.htmlMuted),
            ),
          ),
          
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: _getGridColor(gridType),
            child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          
          // Name & Grid
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                const SizedBox(height: 2),
                Text(gridType.toUpperCase(), style: TextStyle(fontSize: 10, color: _getGridColor(gridType))),
              ],
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

  Color _getGridColor(String gridType) {
    switch (gridType) {
      case 'fortune': return SGColors.htmlGold;
      case 'fanverse': return SGColors.htmlPink;
      case 'gridvoice': return SGColors.htmlGreen;
      default: return SGColors.htmlViolet;
    }
  }
}
