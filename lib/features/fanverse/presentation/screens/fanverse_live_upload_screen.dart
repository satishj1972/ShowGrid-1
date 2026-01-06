// lib/features/fanverse/presentation/screens/fanverse_live_upload_screen.dart
// 2.211 Live / Upload Page - Choose between Photo Flow, Video Flow, or Upload
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';

class FanverseLiveUploadScreen extends StatelessWidget {
  final String episodeId;
  final Map<String, dynamic>? episodeData;

  const FanverseLiveUploadScreen({
    super.key,
    required this.episodeId,
    this.episodeData,
  });

  @override
  Widget build(BuildContext context) {
    final episode = episodeData ?? {'title': 'Episode', 'type': 'both'};
    final type = episode['type'] ?? 'both';

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
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Spacer(),
                      // Episode info
                      _buildEpisodeInfo(episode),
                      const SizedBox(height: 40),
                      // Choose method text
                      const Text(
                        'Choose how to create',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Capture live or upload from gallery',
                        style: TextStyle(fontSize: 13, color: SGColors.htmlMuted),
                      ),
                      const SizedBox(height: 30),
                      // Options
                      Row(
                        children: [
                          // Photo option
                          if (type == 'photo' || type == 'both')
                            Expanded(
                              child: _buildOptionCard(
                                context,
                                icon: Icons.camera_alt,
                                label: 'PHOTO',
                                sublabel: 'Capture live',
                                gradient: const [Color(0xFFFF4FD8), Color(0xFF9B7DFF)],
                                onTap: () => context.go('/fanverse/photo/$episodeId', extra: episodeData),
                              ),
                            ),
                          if ((type == 'photo' || type == 'both') && (type == 'video' || type == 'both'))
                            const SizedBox(width: 12),
                          // Video option
                          if (type == 'video' || type == 'both')
                            Expanded(
                              child: _buildOptionCard(
                                context,
                                icon: Icons.videocam,
                                label: 'VIDEO',
                                sublabel: 'Record now',
                                gradient: const [Color(0xFF9B7DFF), Color(0xFF5CF1FF)],
                                onTap: () => context.go('/fanverse/video/$episodeId', extra: episodeData),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Upload from gallery
                      _buildUploadOption(context),
                      const Spacer(flex: 2),
                      // Tips
                      _buildTipsSection(),
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
            onTap: () => context.go('/fanverse/challenge/$episodeId', extra: episodeData),
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
              color: const Color(0xFF5CF1FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF5CF1FF).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5CF1FF)),
                ),
                const SizedBox(width: 6),
                const Text('LIVE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Color(0xFF5CF1FF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeInfo(Map<String, dynamic> episode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0D0F1A).withOpacity(0.8),
        border: Border.all(color: const Color(0xFFFF4FD8).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(colors: [Color(0xFFFF4FD8), Color(0xFF9B7DFF)]),
            ),
            child: Center(child: Text(episode['icon'] ?? '🎬', style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(episode['title'] ?? 'Episode', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(episode['episode'] ?? '', style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
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
        height: 140,
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradient),
                boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.5), blurRadius: 20)],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
            const SizedBox(height: 4),
            Text(sublabel, style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/fanverse/upload/$episodeId', extra: episodeData),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF0D0F1A).withOpacity(0.8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, color: Colors.white.withOpacity(0.8), size: 22),
            const SizedBox(width: 10),
            Text('UPLOAD FROM GALLERY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF9B7DFF).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF9B7DFF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF9B7DFF), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tip: Good lighting and a steady shot improve your AI score!',
              style: TextStyle(fontSize: 12, color: SGColors.htmlMuted),
            ),
          ),
        ],
      ),
    );
  }
}
