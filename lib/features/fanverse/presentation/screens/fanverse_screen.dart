// lib/features/fanverse/presentation/screens/fanverse_screen.dart
// Fanverse Grid - Loads episodes from Firestore

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class FanverseScreen extends StatelessWidget {
  const FanverseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('episodes')
                      .where('isActive', isEqualTo: true)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: SGColors.htmlPink),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                      );
                    }

                    final episodes = snapshot.data?.docs ?? [];

                    if (episodes.isEmpty) {
                      return const Center(
                        child: Text('No episodes available', style: TextStyle(color: SGColors.htmlMuted)),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      children: [
                        _buildHero(),
                        const SizedBox(height: 20),
                        const Text(
                          'FANVERSE EPISODES',
                          style: TextStyle(fontSize: 13, letterSpacing: 1.8, color: SGColors.htmlMuted),
                        ),
                        const SizedBox(height: 14),
                        ...episodes.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildEpisodeCard(context, doc.id, data);
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
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
          const SizedBox(width: 8),
          const Text(
            'SHOWGRID',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SGColors.borderSubtle),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xF8200820), Color(0xF8100510)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CREATE • RECREATE • CELEBRATE',
            style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: SGColors.htmlMuted),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
              children: [
                const TextSpan(text: 'Magenta\n', style: TextStyle(color: Colors.white)),
                TextSpan(
                  text: 'Fanverse',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFFFF4FD8), Color(0xFF5CF1FF)],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 30)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Recreate iconic scenes from movies, shows, and pop culture. Rated by AI and fans. Show your creative side!',
            style: TextStyle(fontSize: 13, color: SGColors.htmlMuted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard(BuildContext context, String episodeId, Map<String, dynamic> data) {
    final String title = data['title'] ?? 'Episode';
    final String description = data['description'] ?? '';
    final String category = data['category'] ?? 'Category';
    final String difficulty = data['difficulty'] ?? 'Medium';
    final String imageUrl = data['imageUrl'] ?? '';
    final int entriesCount = data['entriesCount'] ?? 0;
    final int likes = data['likes'] ?? 0;

    Color difficultyColor = SGColors.htmlGreen;
    if (difficulty == 'Medium') difficultyColor = SGColors.htmlGold;
    if (difficulty == 'Hard') difficultyColor = SGColors.htmlPink;

    return GestureDetector(
      onTap: () => context.push('/fanverse/challenge/$episodeId', extra: data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SGColors.borderSubtle),
          color: SGColors.htmlGlass,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: SGColors.htmlPink.withOpacity(0.2),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.movie, color: SGColors.htmlPink, size: 30),
                      ),
                    )
                  : const Icon(Icons.movie, color: SGColors.htmlPink, size: 30),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: difficultyColor.withOpacity(0.2),
                        ),
                        child: Text(
                          difficulty,
                          style: TextStyle(fontSize: 10, color: difficultyColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPill(category),
                      const Spacer(),
                      const Icon(Icons.people_outline, size: 14, color: SGColors.htmlMuted),
                      const SizedBox(width: 4),
                      Text('$entriesCount', style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite_border, size: 14, color: SGColors.htmlPink),
                      const SizedBox(width: 4),
                      Text('$likes', style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
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

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: SGColors.htmlPink.withOpacity(0.15),
        border: Border.all(color: SGColors.htmlPink.withOpacity(0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 9, letterSpacing: 0.5, color: SGColors.htmlPink),
      ),
    );
  }
}
