// lib/features/discovery/presentation/screens/discovery_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';
import '../../../../core/services/entry_service.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  String _selectedFilter = 'all';
  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'All'},
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
              Expanded(child: _buildFeed()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 1),
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
            'DISCOVER',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
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

  Widget _buildFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: EntryService.getDiscoveryFeed(
        gridType: _selectedFilter == 'all' ? null : _selectedFilter,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SGColors.htmlViolet));
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
                Icon(Icons.explore_outlined, size: 60, color: SGColors.htmlMuted),
                SizedBox(height: 16),
                Text('No entries yet', style: TextStyle(fontSize: 16, color: SGColors.htmlMuted)),
                SizedBox(height: 8),
                Text('Be the first to share!', style: TextStyle(fontSize: 14, color: SGColors.htmlMuted)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index].data() as Map<String, dynamic>;
            final entryId = entries[index].id;
            return _buildEntryCard(entryId, entry);
          },
        );
      },
    );
  }

  Widget _buildEntryCard(String entryId, Map<String, dynamic> entry) {
    final score = entry['aiScore']?['overallScore'] ?? 0.0;
    final grade = entry['aiScore']?['grade'] ?? '-';
    final userName = entry['userName'] ?? 'Anonymous';
    final gridType = entry['gridType'] ?? 'fortune';
    final likes = entry['likes'] ?? 0;
    final mediaType = entry['mediaType'] ?? 'photo';

    return GestureDetector(
      onTap: () => _showEntryDetail(entryId, entry),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SGColors.borderSubtle),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: entry['thumbnailUrl'] != null || entry['mediaUrl'] != null
                  ? Image.network(
                      entry['thumbnailUrl'] ?? entry['mediaUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(gridType),
                    )
                  : _buildPlaceholder(gridType),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            // Grid type badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _getGridColor(gridType).withOpacity(0.9),
                ),
                child: Text(
                  gridType.toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
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
                  color: Colors.black54,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: SGColors.htmlGold),
                    const SizedBox(width: 4),
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Video icon
            if (mediaType == 'video')
              const Positioned(
                top: 40,
                left: 8,
                child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 20),
              ),

            // Audio icon
            if (mediaType == 'audio')
              const Positioned(
                top: 40,
                left: 8,
                child: Icon(Icons.headphones, color: Colors.white70, size: 20),
              ),

            // Bottom info
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: _getGridColor(gridType),
                        child: Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Actions row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _likeEntry(entryId),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_border, size: 16, color: SGColors.htmlPink),
                            const SizedBox(width: 4),
                            Text('$likes', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Text(grade, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _getGradeColor(grade))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String gridType) {
    return Container(
      color: _getGridColor(gridType).withOpacity(0.3),
      child: Center(
        child: Icon(
          gridType == 'gridvoice' ? Icons.mic : Icons.image,
          size: 40,
          color: _getGridColor(gridType),
        ),
      ),
    );
  }

  void _showEntryDetail(String entryId, Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SGColors.carbonBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _buildDetailSheet(scrollController, entryId, entry),
      ),
    );
  }

  Widget _buildDetailSheet(ScrollController controller, String entryId, Map<String, dynamic> entry) {
    final score = entry['aiScore']?['overallScore'] ?? 0.0;
    final feedback = entry['aiScore']?['feedback'] ?? '';
    final highlights = List<String>.from(entry['aiScore']?['highlights'] ?? []);
    final userName = entry['userName'] ?? 'Anonymous';

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: SGColors.htmlMuted,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Media preview
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: entry['mediaUrl'] != null
                ? Image.network(entry['thumbnailUrl'] ?? entry['mediaUrl'], fit: BoxFit.cover)
                : Container(color: SGColors.htmlGlass),
          ),
        ),
        const SizedBox(height: 20),

        // User & Score
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: SGColors.htmlViolet,
              child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text(entry['gridType']?.toUpperCase() ?? '', style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [SGColors.htmlViolet, SGColors.htmlPink]),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(score.toStringAsFixed(1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // AI Feedback
        if (feedback.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: SGColors.htmlGlass,
              border: Border.all(color: SGColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: SGColors.htmlCyan),
                    SizedBox(width: 8),
                    Text('AI Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SGColors.htmlCyan)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(feedback, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Highlights
        if (highlights.isNotEmpty) ...[
          const Text('Highlights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SGColors.htmlGreen)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: highlights.map((h) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: SGColors.htmlGreen.withOpacity(0.1),
                border: Border.all(color: SGColors.htmlGreen.withOpacity(0.3)),
              ),
              child: Text(h, style: const TextStyle(fontSize: 12, color: SGColors.htmlGreen)),
            )).toList(),
          ),
        ],
        const SizedBox(height: 20),

        // Like button
        ElevatedButton.icon(
          onPressed: () {
            _likeEntry(entryId);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.favorite),
          label: Text('Like (${entry['likes'] ?? 0})'),
          style: ElevatedButton.styleFrom(
            backgroundColor: SGColors.htmlPink,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  void _likeEntry(String entryId) {
    EntryService.likeEntry(entryId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❤️ Liked!'), duration: Duration(seconds: 1)),
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

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return SGColors.htmlGreen;
    if (grade.startsWith('B')) return SGColors.htmlCyan;
    if (grade.startsWith('C')) return SGColors.htmlGold;
    return Colors.redAccent;
  }
}
