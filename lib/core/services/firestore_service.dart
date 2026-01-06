// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get users => _db.collection('users');
  CollectionReference get challenges => _db.collection('challenges');
  CollectionReference get entries => _db.collection('entries');
  CollectionReference get episodes => _db.collection('episodes');
  CollectionReference get chapters => _db.collection('chapters');

  // Create user on first login
  Future<void> createUserOnFirstLogin({
    required String uid,
    String? phone,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    final userDoc = await users.doc(uid).get();
    if (!userDoc.exists) {
      await users.doc(uid).set({
        'uid': uid,
        'phone': phone,
        'email': email,
        'displayName': displayName ?? 'ShowGrid User',
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'totalEntries': 0,
        'totalLikes': 0,
        'credits': 10,
      });
    }
  }

  // Get active challenges
  Stream<QuerySnapshot> streamActiveChallenges() {
    return challenges.where('isActive', isEqualTo: true).snapshots();
  }

  // Get active episodes
  Stream<QuerySnapshot> streamActiveEpisodes() {
    return episodes.where('isActive', isEqualTo: true).snapshots();
  }

  // Get active chapters
  Stream<QuerySnapshot> streamActiveChapters() {
    return chapters.where('isActive', isEqualTo: true).snapshots();
  }

  // Submit entry
  Future<String> submitEntry({
    required String userId,
    required String gridType,
    required String contestId,
    required String mediaType,
    required String mediaUrl,
    required String thumbnailUrl,
    String? caption,
  }) async {
    final docRef = await entries.add({
      'userId': userId,
      'gridType': gridType,
      'contestId': contestId,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'createdAt': FieldValue.serverTimestamp(),
      'aiScore': null,
      'humanScore': 0.0,
      'totalScore': 0.0,
      'likes': 0,
      'status': 'pending',
    });
    await users.doc(userId).update({'totalEntries': FieldValue.increment(1)});
    return docRef.id;
  }

  // Get user entries
  Stream<QuerySnapshot> streamUserEntries(String userId) {
    return entries.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).snapshots();
  }

  // Get leaderboard
  Stream<QuerySnapshot> streamLeaderboard(String contestId, {int limit = 50}) {
    return entries
        .where('contestId', isEqualTo: contestId)
        .where('status', isEqualTo: 'approved')
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Discovery feed
  Stream<QuerySnapshot> streamDiscoveryFeed({int limit = 50}) {
    return entries
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }
}
