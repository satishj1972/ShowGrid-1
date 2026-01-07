// lib/core/services/ai_scoring_service.dart
import 'package:cloud_functions/cloud_functions.dart';

class AIScoringService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<AIScoreResult> scoreImage({
    String? imageBase64,
    String? imageUrl,
    required String challengeTitle,
    required String challengeDescription,
    String? challengeCategory,
  }) async {
    try {
      final callable = _functions.httpsCallable('scoreImage');
      final response = await callable.call({
        'imageBase64': imageBase64,
        'imageUrl': imageUrl,
        'challengeTitle': challengeTitle,
        'challengeDescription': challengeDescription,
        'challengeCategory': challengeCategory,
      });

      final data = Map<String, dynamic>.from(response.data);
      return AIScoreResult(
        creativity: (data['creativity'] as num).toDouble(),
        quality: (data['quality'] as num).toDouble(),
        relevance: (data['relevance'] as num).toDouble(),
        impact: (data['impact'] as num).toDouble(),
        effort: (data['effort'] as num).toDouble(),
        overallScore: (data['overall_score'] as num).toDouble(),
        feedback: data['feedback'] as String,
        highlights: List<String>.from(data['highlights'] ?? []),
        improvements: List<String>.from(data['improvements'] ?? []),
      );
    } on FirebaseFunctionsException catch (e) {
      return AIScoreResult.error(e.message ?? 'Scoring failed');
    } catch (e) {
      return AIScoreResult.error('Scoring failed: $e');
    }
  }

  static Future<AIScoreResult> scoreAudio({
    required String transcript,
    required String chapterTitle,
    required String chapterDescription,
  }) async {
    try {
      final callable = _functions.httpsCallable('scoreAudio');
      final response = await callable.call({
        'transcript': transcript,
        'chapterTitle': chapterTitle,
        'chapterDescription': chapterDescription,
      });

      final data = Map<String, dynamic>.from(response.data);
      return AIScoreResult(
        creativity: (data['storytelling'] as num?)?.toDouble() ?? 0,
        quality: (data['clarity'] as num?)?.toDouble() ?? 0,
        relevance: (data['relevance'] as num).toDouble(),
        impact: (data['emotional_impact'] as num?)?.toDouble() ?? 0,
        effort: (data['authenticity'] as num?)?.toDouble() ?? 0,
        overallScore: (data['overall_score'] as num).toDouble(),
        feedback: data['feedback'] as String,
        highlights: List<String>.from(data['highlights'] ?? []),
        improvements: List<String>.from(data['improvements'] ?? []),
      );
    } on FirebaseFunctionsException catch (e) {
      return AIScoreResult.error(e.message ?? 'Scoring failed');
    } catch (e) {
      return AIScoreResult.error('Scoring failed: $e');
    }
  }
}

class AIScoreResult {
  final bool success;
  final String? errorMessage;
  final double creativity, quality, relevance, impact, effort, overallScore;
  final String feedback;
  final List<String> highlights, improvements;

  AIScoreResult({
    this.success = true,
    this.errorMessage,
    this.creativity = 0,
    this.quality = 0,
    this.relevance = 0,
    this.impact = 0,
    this.effort = 0,
    this.overallScore = 0,
    this.feedback = '',
    this.highlights = const [],
    this.improvements = const [],
  });

  factory AIScoreResult.error(String msg) => AIScoreResult(success: false, errorMessage: msg);

  String get grade {
    if (overallScore >= 9) return 'A+';
    if (overallScore >= 8.5) return 'A';
    if (overallScore >= 8) return 'A-';
    if (overallScore >= 7.5) return 'B+';
    if (overallScore >= 7) return 'B';
    if (overallScore >= 6) return 'C+';
    if (overallScore >= 5) return 'C';
    return 'D';
  }
}
