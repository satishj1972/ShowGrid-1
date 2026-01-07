// lib/features/gridvoice/presentation/screens/gridvoice_screen.dart
// GridVoice - Loads chapters from Firestore

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';

class GridVoiceScreen extends StatelessWidget {
  const GridVoiceScreen({super.key});

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
                      .collection('chapters')
                      .where('isActive', isEqualTo: true)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: SGColors.htmlGreen),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                      );
                    }

                    final chapters = snapshot.data?.docs ?? [];

                    if (chapters.isEmpty) {
                      return const Center(
                        child: Text('No chapters available', style: TextStyle(color: SGColors.htmlMuted)),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      children: [
                        _buildHero(),
                        const SizedBox(height: 20),
                        const Text(
                          'VOICE CHAPTERS',
                          style: TextStyle(fontSize: 13, letterSpacing: 1.8, color: SGColors.htmlMuted),
                        ),
                        const SizedBox(height: 14),
                        ...chapters.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildChapterCard(context, doc.id, data);
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
          colors: [Color(0xF8082010), Color(0xF8051008)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STORIES • VOICES • PEOPLE',
            style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: SGColors.htmlMuted),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
              children: [
                const TextSpan(text: 'GridVoice\n', style: TextStyle(color: Colors.white)),
                TextSpan(
                  text: 'Tamil Nadu',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF4ADE80), Color(0xFF5CF1FF)],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 30)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Share stories of people and places. Record your voice, share experiences, and connect through audio narratives.',
            style: TextStyle(fontSize: 13, color: SGColors.htmlMuted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, String chapterId, Map<String, dynamic> data) {
    final String title = data['title'] ?? 'Chapter';
    final String description = data['description'] ?? '';
    final String category = data['category'] ?? 'Category';
    final String imageUrl = data['imageUrl'] ?? '';
    final int entriesCount = data['entriesCount'] ?? 0;
    final int maxDuration = data['maxDuration'] ?? 180;

    return GestureDetector(
      onTap: () => context.push('/gridvoice/challenge/$chapterId', extra: data),
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: SGColors.htmlGreen.withOpacity(0.2),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.mic, color: SGColors.htmlGreen, size: 28),
                      ),
                    )
                  : const Icon(Icons.mic, color: SGColors.htmlGreen, size: 28),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
                      const SizedBox(width: 8),
                      _buildPill('${maxDuration ~/ 60} MIN MAX'),
                      const Spacer(),
                      const Icon(Icons.headphones, size: 14, color: SGColors.htmlMuted),
                      const SizedBox(width: 4),
                      Text('$entriesCount stories', style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
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
        color: SGColors.htmlGreen.withOpacity(0.15),
        border: Border.all(color: SGColors.htmlGreen.withOpacity(0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 9, letterSpacing: 0.5, color: SGColors.htmlGreen),
      ),
    );
  }
}
