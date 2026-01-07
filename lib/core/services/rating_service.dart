// lib/core/services/rating_service.dart
// Handles human ratings on entries

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Rate an entry (1-10 scale)
  static Future<RatingResult> rateEntry({
    required String entryId,
    required double rating,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return RatingResult.error('Please log in to rate');
      }

      // Check if user already rated this entry
      final existingRating = await _db
          .collection('ratings')
          .where('entryId', isEqualTo: entryId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // Update existing rating
        await existingRating.docs.first.reference.update({
          'rating': rating,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new rating
        await _db.collection('ratings').add({
          'entryId': entryId,
          'userId': user.uid,
          'rating': rating,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Recalculate average human score for the entry
      await _updateEntryHumanScore(entryId);

      return RatingResult(success: true);
    } catch (e) {
      return RatingResult.error('Failed to submit rating: $e');
    }
  }

  // Get user's rating for an entry
  static Future<double?> getUserRating(String entryId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final rating = await _db
        .collection('ratings')
        .where('entryId', isEqualTo: entryId)
        .where('userId', isEqualTo: user.uid)
        .get();

    if (rating.docs.isEmpty) return null;
    return (rating.docs.first.data()['rating'] as num).toDouble();
  }

  // Get all ratings for an entry
  static Stream<QuerySnapshot> getEntryRatings(String entryId) {
    return _db
        .collection('ratings')
        .where('entryId', isEqualTo: entryId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update entry's human score (average of all ratings)
  static Future<void> _updateEntryHumanScore(String entryId) async {
    final ratings = await _db
        .collection('ratings')
        .where('entryId', isEqualTo: entryId)
        .get();

    if (ratings.docs.isEmpty) return;

    // Calculate average
    double total = 0;
    for (var doc in ratings.docs) {
      total += (doc.data()['rating'] as num).toDouble();
    }
    final avgHumanScore = total / ratings.docs.length;

    // Get current entry data
    final entryDoc = await _db.collection('entries').doc(entryId).get();
    if (!entryDoc.exists) return;

    final entryData = entryDoc.data()!;
    final aiScore = (entryData['aiScore']?['overallScore'] ?? 0.0).toDouble();

    // Calculate combined score (60% AI + 40% Human)
    final combinedScore = (aiScore * 0.6) + (avgHumanScore * 0.4);

    // Update entry
    await _db.collection('entries').doc(entryId).update({
      'humanScore': avgHumanScore,
      'humanRatingsCount': ratings.docs.length,
      'finalScore': combinedScore,
    });
  }

  // Check if user can rate (can't rate own entry)
  static Future<bool> canUserRate(String entryId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final entry = await _db.collection('entries').doc(entryId).get();
    if (!entry.exists) return false;

    return entry.data()!['userId'] != user.uid;
  }

  // Get entries for user to rate (not their own, not already rated)
  static Future<List<DocumentSnapshot>> getEntriesToRate({int limit = 10}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // Get user's already rated entries
    final userRatings = await _db
        .collection('ratings')
        .where('userId', isEqualTo: user.uid)
        .get();
    
    final ratedEntryIds = userRatings.docs.map((d) => d.data()['entryId'] as String).toSet();

    // Get entries not by current user
    final entries = await _db
        .collection('entries')
        .where('status', isEqualTo: 'scored')
        .where('userId', isNotEqualTo: user.uid)
        .orderBy('userId')
        .orderBy('createdAt', descending: true)
        .limit(limit + ratedEntryIds.length)
        .get();

    // Filter out already rated
    return entries.docs.where((doc) => !ratedEntryIds.contains(doc.id)).take(limit).toList();
  }
}

class RatingResult {
  final bool success;
  final String? errorMessage;

  RatingResult({this.success = true, this.errorMessage});

  factory RatingResult.error(String msg) => RatingResult(success: false, errorMessage: msg);
}
