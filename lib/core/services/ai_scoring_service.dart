// lib/core/services/ai_scoring_service.dart
// AI Scoring Service using OpenAI GPT-4 Vision

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIScoringService {
  static String? _apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  static void setApiKey(String key) {
    _apiKey = key;
  }

  static bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  // Score an image based on challenge criteria
  static Future<AIScoreResult> scoreImage({
    required String imageBase64,
    required String challengeTitle,
    required String challengeDescription,
    String? challengeCategory,
  }) async {
    if (!isConfigured) {
      return AIScoreResult.error('API key not configured');
    }

    try {
      final prompt = _buildScoringPrompt(
        challengeTitle: challengeTitle,
        challengeDescription: challengeDescription,
        challengeCategory: challengeCategory,
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert judge for a creative content competition app called ShowGrid. 
Your job is to fairly evaluate submissions based on specific criteria.
Always respond in valid JSON format only, with no additional text.'''
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$imageBase64',
                    'detail': 'high',
                  },
                },
              ],
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseScoreResponse(content);
      } else {
        final error = jsonDecode(response.body);
        return AIScoreResult.error(error['error']['message'] ?? 'API error: ${response.statusCode}');
      }
    } catch (e) {
      return AIScoreResult.error('Scoring failed: $e');
    }
  }

  // Score from image URL
  static Future<AIScoreResult> scoreImageUrl({
    required String imageUrl,
    required String challengeTitle,
    required String challengeDescription,
    String? challengeCategory,
  }) async {
    if (!isConfigured) {
      return AIScoreResult.error('API key not configured');
    }

    try {
      final prompt = _buildScoringPrompt(
        challengeTitle: challengeTitle,
        challengeDescription: challengeDescription,
        challengeCategory: challengeCategory,
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert judge for ShowGrid, a creative content competition app.
Always respond in valid JSON format only.'''
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {'type': 'image_url', 'image_url': {'url': imageUrl, 'detail': 'high'}},
              ],
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseScoreResponse(content);
      } else {
        final error = jsonDecode(response.body);
        return AIScoreResult.error(error['error']['message'] ?? 'API error');
      }
    } catch (e) {
      return AIScoreResult.error('Scoring failed: $e');
    }
  }

  static String _buildScoringPrompt({
    required String challengeTitle,
    required String challengeDescription,
    String? challengeCategory,
  }) {
    return '''
You are judging a submission for: "$challengeTitle"
Description: $challengeDescription
${challengeCategory != null ? 'Category: $challengeCategory' : ''}

Evaluate this submission and provide scores from 1-10:
1. **Creativity** - How original and creative?
2. **Quality** - Technical quality, lighting, composition
3. **Relevance** - How well does it match the challenge?
4. **Impact** - Visual impact and emotional connection
5. **Effort** - Apparent effort put into it

Respond ONLY with valid JSON:
{
  "creativity": <score>,
  "quality": <score>,
  "relevance": <score>,
  "impact": <score>,
  "effort": <score>,
  "overall_score": <weighted_average>,
  "feedback": "<2-3 sentence feedback>",
  "highlights": ["<strength1>", "<strength2>"],
  "improvements": ["<tip1>", "<tip2>"]
}
''';
  }

  static AIScoreResult _parseScoreResponse(String content) {
    try {
      String cleanContent = content.trim();
      if (cleanContent.startsWith('```json')) cleanContent = cleanContent.substring(7);
      if (cleanContent.startsWith('```')) cleanContent = cleanContent.substring(3);
      if (cleanContent.endsWith('```')) cleanContent = cleanContent.substring(0, cleanContent.length - 3);
      cleanContent = cleanContent.trim();

      final json = jsonDecode(cleanContent);
      
      return AIScoreResult(
        creativity: (json['creativity'] as num).toDouble(),
        quality: (json['quality'] as num).toDouble(),
        relevance: (json['relevance'] as num).toDouble(),
        impact: (json['impact'] as num).toDouble(),
        effort: (json['effort'] as num).toDouble(),
        overallScore: (json['overall_score'] as num).toDouble(),
        feedback: json['feedback'] as String,
        highlights: List<String>.from(json['highlights'] ?? []),
        improvements: List<String>.from(json['improvements'] ?? []),
      );
    } catch (e) {
      return AIScoreResult.error('Failed to parse score: $e');
    }
  }
}

class AIScoreResult {
  final bool success;
  final String? errorMessage;
  final double creativity;
  final double quality;
  final double relevance;
  final double impact;
  final double effort;
  final double overallScore;
  final String feedback;
  final List<String> highlights;
  final List<String> improvements;

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

  factory AIScoreResult.error(String message) {
    return AIScoreResult(success: false, errorMessage: message);
  }

  String get grade {
    if (overallScore >= 9) return 'A+';
    if (overallScore >= 8.5) return 'A';
    if (overallScore >= 8) return 'A-';
    if (overallScore >= 7.5) return 'B+';
    if (overallScore >= 7) return 'B';
    if (overallScore >= 6.5) return 'B-';
    if (overallScore >= 6) return 'C+';
    if (overallScore >= 5.5) return 'C';
    if (overallScore >= 5) return 'C-';
    return 'D';
  }
}
