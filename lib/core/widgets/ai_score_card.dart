// lib/core/widgets/ai_score_card.dart
import 'package:flutter/material.dart';
import '../theme/sg_colors.dart';

class AIScoreCard extends StatelessWidget {
  final Map<String, dynamic> scoreData;
  final VoidCallback? onRetry;

  const AIScoreCard({super.key, required this.scoreData, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final overallScore = (scoreData['overallScore'] ?? 0.0).toDouble();
    final grade = scoreData['grade'] ?? 'B';
    final feedback = scoreData['feedback'] ?? '';
    final highlights = List<String>.from(scoreData['highlights'] ?? []);
    final improvements = List<String>.from(scoreData['improvements'] ?? []);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: SGColors.htmlGlass,
        border: Border.all(color: SGColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with score
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_getScoreColor(overallScore), _getScoreColor(overallScore).withOpacity(0.5)],
                  ),
                ),
                child: Center(
                  child: Text(
                    overallScore.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Score', style: TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
                    Text('Grade: $grade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _getScoreColor(overallScore))),
                  ],
                ),
              ),
              const Icon(Icons.auto_awesome, color: SGColors.htmlGold, size: 28),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: SGColors.borderSubtle),
          const SizedBox(height: 16),

          // Score breakdown
          _buildScoreRow('Creativity', (scoreData['creativity'] ?? 0.0).toDouble()),
          _buildScoreRow('Quality', (scoreData['quality'] ?? 0.0).toDouble()),
          _buildScoreRow('Relevance', (scoreData['relevance'] ?? 0.0).toDouble()),
          _buildScoreRow('Impact', (scoreData['impact'] ?? 0.0).toDouble()),
          _buildScoreRow('Effort', (scoreData['effort'] ?? 0.0).toDouble()),

          const SizedBox(height: 16),
          const Divider(color: SGColors.borderSubtle),
          const SizedBox(height: 16),

          // Feedback
          const Text('Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text(feedback, style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted, height: 1.4)),

          // Highlights
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Highlights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SGColors.htmlGreen)),
            const SizedBox(height: 8),
            ...highlights.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: SGColors.htmlGreen),
                  const SizedBox(width: 8),
                  Expanded(child: Text(h, style: const TextStyle(fontSize: 12, color: Colors.white70))),
                ],
              ),
            )),
          ],

          // Improvements
          if (improvements.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('To Improve', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SGColors.htmlGold)),
            const SizedBox(height: 8),
            ...improvements.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 14, color: SGColors.htmlGold),
                  const SizedBox(width: 8),
                  Expanded(child: Text(i, style: const TextStyle(fontSize: 12, color: Colors.white70))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 10,
                backgroundColor: SGColors.borderSubtle,
                valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 30, child: Text(score.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return SGColors.htmlGreen;
    if (score >= 6) return SGColors.htmlGold;
    if (score >= 4) return Colors.orange;
    return Colors.redAccent;
  }
}
