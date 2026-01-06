// lib/features/gridvoice/presentation/screens/gridvoice_live_upload_screen.dart
// 2.311 Live / Upload Page - Choose between Audio Flow or Upload Flow
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';

class GridVoiceLiveUploadScreen extends StatelessWidget {
  final String chapterId;
  final Map<String, dynamic>? chapterData;

  const GridVoiceLiveUploadScreen({
    super.key,
    required this.chapterId,
    this.chapterData,
  });

  @override
  Widget build(BuildContext context) {
    final chapter = chapterData ?? {'title': 'Chapter', 'icon': '📸'};

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
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Spacer(),
                      _buildChapterInfo(chapter),
                      const SizedBox(height: 40),
                      const Text(
                        'Share your story',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Record a voice story or upload existing content',
                        style: TextStyle(fontSize: 13, color: SGColors.htmlMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Main options
                      Row(
                        children: [
                          // Audio Recording option
                          Expanded(
                            child: _buildOptionCard(
                              context,
                              icon: Icons.mic,
                              label: 'RECORD',
                              sublabel: 'Voice Story',
                              gradient: const [Color(0xFF5CFFB1), Color(0xFF5CA8FF)],
                              onTap: () => context.go('/gridvoice/audio/$chapterId', extra: chapterData),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Upload option
                          Expanded(
                            child: _buildOptionCard(
                              context,
                              icon: Icons.cloud_upload,
                              label: 'UPLOAD',
                              sublabel: 'Photo/Video/Audio',
                              gradient: const [Color(0xFF5CA8FF), Color(0xFF9B7DFF)],
                              onTap: () => context.go('/gridvoice/upload/$chapterId', extra: chapterData),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 2),
                      // Info section
                      _buildInfoSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/gridvoice/challenge/$chapterId', extra: chapterData),
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
                  Text('Back', style: TextStyle(fontSize: 13, color: Color(0xFFA7B0C6))),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5CFFB1)),
                ),
                const SizedBox(width: 6),
                const Text('CREATE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Color(0xFF5CFFB1))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterInfo(Map<String, dynamic> chapter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0D0F1A).withOpacity(0.8),
        border: Border.all(color: const Color(0xFF5CFFB1).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(colors: [Color(0xFF5CFFB1), Color(0xFF5CA8FF)]),
            ),
            child: Center(child: Text(chapter['icon'] ?? '📸', style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chapter['title'] ?? 'Chapter', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(chapter['chapter'] ?? '', style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradient[0].withOpacity(0.3), gradient[1].withOpacity(0.1)],
          ),
          border: Border.all(color: gradient[0].withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradient),
                boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.5), blurRadius: 20)],
              ),
              child: Icon(icon, color: const Color(0xFF050611), size: 32),
            ),
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
            const SizedBox(height: 4),
            Text(sublabel, style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF5CA8FF).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF5CA8FF).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF5CA8FF), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Voice stories get 20% higher engagement!',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF5CA8FF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Record your story in Tamil, English, or any local language. Share the context behind your photo or video.',
            style: TextStyle(fontSize: 11, color: SGColors.htmlMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
