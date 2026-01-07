// lib/core/widgets/ai_score_card.dart
import 'package:flutter/material.dart';
import '../services/ai_scoring_service.dart';
import '../theme/sg_colors.dart';

class AIScoreCard extends StatelessWidget {
  final AIScoreResult result;
  final VoidCallback? onRetry;

  const AIScoreCard({super.key, required this.result, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (!result.success) return _buildErrorCard();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)],
        ),
        border: Border.all(color: SGColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(colors: [SGColors.htmlViolet, SGColors.htmlPink]),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('AI SCORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
                  ],
                ),
              ),
              const Spacer(),
              Text(result.grade, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _getGradeColor(result.grade))),
            ],
          ),
          const SizedBox(height: 24),

          // Main Score Circle
          _buildScoreCircle(),
          const SizedBox(height: 24),

          // Score Breakdown
          _buildScoreRow('Creativity', result.creativity, Icons.lightbulb_outline),
          const SizedBox(height: 10),
          _buildScoreRow('Quality', result.quality, Icons.high_quality_outlined),
          const SizedBox(height: 10),
          _buildScoreRow('Relevance', result.relevance, Icons.check_circle_outline),
          const SizedBox(height: 10),
          _buildScoreRow('Impact', result.impact, Icons.flash_on_outlined),
          const SizedBox(height: 10),
          _buildScoreRow('Effort', result.effort, Icons.emoji_events_outlined),
          const SizedBox(height: 20),

          // Feedback
          Container(
            padding: const EdgeInsets.all(14),
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
                    Icon(Icons.chat_bubble_outline, size: 16, color: SGColors.htmlCyan),
                    SizedBox(width: 8),
                    Text('AI Feedback', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SGColors.htmlCyan)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(result.feedback, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.5)),
              ],
            ),
          ),

          // Highlights & Tips
          if (result.highlights.isNotEmpty || result.improvements.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.highlights.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.thumb_up_outlined, size: 14, color: SGColors.htmlGreen),
                            SizedBox(width: 6),
                            Text('Strengths', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SGColors.htmlGreen)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...result.highlights.map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $h', style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
                        )),
                      ],
                    ),
                  ),
                if (result.improvements.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tips_and_updates_outlined, size: 14, color: SGColors.htmlGold),
                            SizedBox(width: 6),
                            Text('Tips', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SGColors.htmlGold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...result.improvements.map((i) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $i', style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
                        )),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Scoring Failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text(result.errorMessage ?? 'Unknown error', style: const TextStyle(fontSize: 14, color: SGColors.htmlMuted), textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: SGColors.htmlViolet),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(value: 1, strokeWidth: 8, backgroundColor: SGColors.borderSubtle, valueColor: const AlwaysStoppedAnimation(SGColors.htmlGlass)),
        ),
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(value: result.overallScore / 10, strokeWidth: 8, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation(_getScoreColor(result.overallScore))),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result.overallScore.toStringAsFixed(1), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white)),
            const Text('out of 10', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, double score, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SGColors.htmlMuted),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted))),
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: score / 10, backgroundColor: SGColors.borderSubtle, valueColor: AlwaysStoppedAnimation(_getScoreColor(score)), minHeight: 6),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 32, child: Text(score.toStringAsFixed(1), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _getScoreColor(score)), textAlign: TextAlign.right)),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return SGColors.htmlGreen;
    if (score >= 6) return SGColors.htmlCyan;
    if (score >= 4) return SGColors.htmlGold;
    return Colors.redAccent;
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return SGColors.htmlGreen;
    if (grade.startsWith('B')) return SGColors.htmlCyan;
    if (grade.startsWith('C')) return SGColors.htmlGold;
    return Colors.redAccent;
  }
}
