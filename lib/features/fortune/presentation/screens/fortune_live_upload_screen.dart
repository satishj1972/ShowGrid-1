// lib/features/fortune/presentation/screens/fortune_live_upload_screen.dart
// 2.111 Live / Upload Page - Choose between Photo Flow, Video Flow, or Upload
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';

class FortuneLiveUploadScreen extends StatelessWidget {
  final String challengeId;
  final Map<String, dynamic>? challengeData;

  const FortuneLiveUploadScreen({super.key, required this.challengeId, this.challengeData});

  @override
  Widget build(BuildContext context) {
    final challenge = challengeData ?? {'title': 'Challenge', 'type': 'both', 'icon': '🎯'};
    final type = challenge['type'] ?? 'both';

    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTopBar(context),
                const Spacer(),
                _buildChallengeInfo(challenge),
                const SizedBox(height: 40),
                const Text('Choose how to capture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Capture live or upload from gallery', style: TextStyle(fontSize: 13, color: SGColors.htmlMuted)),
                const SizedBox(height: 30),
                Row(
                  children: [
                    if (type == 'photo' || type == 'both')
                      Expanded(
                        child: _buildOptionCard(
                          context, icon: Icons.camera_alt, label: 'PHOTO', sublabel: 'Capture live',
                          gradient: [const Color(0xFFFFB84D), const Color(0xFFFF4FD8)],
                          onTap: () => context.go('/fortune/photo/$challengeId', extra: challengeData),
                        ),
                      ),
                    if ((type == 'photo' || type == 'both') && (type == 'video' || type == 'both')) const SizedBox(width: 12),
                    if (type == 'video' || type == 'both')
                      Expanded(
                        child: _buildOptionCard(
                          context, icon: Icons.videocam, label: 'VIDEO', sublabel: 'Record now',
                          gradient: [const Color(0xFFFF4FD8), const Color(0xFF5CF1FF)],
                          onTap: () => context.go('/fortune/video/$challengeId', extra: challengeData),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildUploadOption(context),
                const Spacer(flex: 2),
                _buildTipsSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.go('/fortune/challenge/$challengeId', extra: challengeData),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF0D0F1A).withOpacity(0.8), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF23263A))),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.arrow_back, color: Color(0xFFA7B0C6), size: 16), SizedBox(width: 6), Text('Back', style: TextStyle(fontSize: 13, color: Color(0xFFA7B0C6)))]),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFF5CF1FF).withOpacity(0.15), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF5CF1FF).withOpacity(0.5))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5CF1FF))), const SizedBox(width: 6), const Text('LIVE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Color(0xFF5CF1FF)))]),
        ),
      ],
    );
  }

  Widget _buildChallengeInfo(Map<String, dynamic> challenge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: const Color(0xFF0D0F1A).withOpacity(0.8), border: Border.all(color: const Color(0xFFFFB84D).withOpacity(0.3))),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFFFFB84D), Color(0xFFFF4FD8)])), child: Center(child: Text(challenge['icon'] ?? '🎯', style: const TextStyle(fontSize: 26)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(challenge['title'] ?? 'Challenge', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)), const SizedBox(height: 4), Text(challenge['zone'] ?? '', style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted))])),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String label, required String sublabel, required List<Color> gradient, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [gradient[0].withOpacity(0.3), gradient[1].withOpacity(0.1)]), border: Border.all(color: gradient[0].withOpacity(0.5))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: gradient), boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.5), blurRadius: 20)]), child: Icon(icon, color: Colors.white, size: 28)),
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
      onTap: () => context.go('/fortune/upload/$challengeId', extra: challengeData),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFF0D0F1A).withOpacity(0.8), border: Border.all(color: Colors.white.withOpacity(0.2))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.photo_library, color: Colors.white.withOpacity(0.8), size: 22), const SizedBox(width: 10), Text('UPLOAD FROM GALLERY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Colors.white.withOpacity(0.8)))]),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFFFFB84D).withOpacity(0.1), border: Border.all(color: const Color(0xFFFFB84D).withOpacity(0.3))),
      child: Row(children: const [Icon(Icons.lightbulb_outline, color: Color(0xFFFFB84D), size: 20), SizedBox(width: 10), Expanded(child: Text('Tip: Good lighting and a steady shot improve your AI score!', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted)))]),
    );
  }
}
