// lib/core/utils/seed_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedAllData() async {
    await seedChallenges();
    await seedEpisodes();
    await seedChapters();
    print('✅ All data seeded!');
  }

  static Future<void> seedChallenges() async {
    final collection = _db.collection('challenges');
    final existing = await collection.limit(2).get();
    if (existing.docs.length >= 2) return;

    final challenges = [
      {
        'title': 'Food Grid Hunt',
        'description': 'Capture the moment of the first bite — steam, chaos, smiles and the people behind the food.',
        'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
        'zone': 'Food Street',
        'mediaType': 'photo_video',
        'targetAudience': 'Family • College',
        'isActive': true,
        'maxDuration': 60,
        'entriesCount': 234,
        'prizePool': '₹50,000',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Style Street Runway',
        'description': 'Turn walkways into your runway. Capture OOTDs, twirls, squad fits and bold street style.',
        'imageUrl': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
        'zone': 'Fashion Street',
        'mediaType': 'video',
        'targetAudience': 'Teens • Women',
        'isActive': true,
        'maxDuration': 60,
        'entriesCount': 189,
        'prizePool': '₹40,000',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Family Fun Quest',
        'description': 'Capture precious family moments - laughter, bonding, and candid memories that last forever.',
        'imageUrl': 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800',
        'zone': 'Family Zone',
        'mediaType': 'photo_video',
        'targetAudience': 'All Ages',
        'isActive': true,
        'maxDuration': 90,
        'entriesCount': 156,
        'prizePool': '₹35,000',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Campus Vibes',
        'description': 'Show off your college life - friends, hangouts, study sessions, and everything in between.',
        'imageUrl': 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
        'zone': 'College Zone',
        'mediaType': 'video',
        'targetAudience': 'College Students',
        'isActive': true,
        'maxDuration': 60,
        'entriesCount': 312,
        'prizePool': '₹45,000',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Pet Paradise',
        'description': 'Your furry friends deserve the spotlight! Capture cute, funny, or heartwarming pet moments.',
        'imageUrl': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800',
        'zone': 'Pet Zone',
        'mediaType': 'photo',
        'targetAudience': 'Pet Lovers',
        'isActive': true,
        'maxDuration': 30,
        'entriesCount': 278,
        'prizePool': '₹30,000',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Sunset Chasers',
        'description': 'Chase the golden hour! Capture stunning sunsets, silhouettes, and magical evening moments.',
        'imageUrl': 'https://images.unsplash.com/photo-1495616811223-4d98c6e9c869?w=800',
        'zone': 'Outdoor Zone',
        'mediaType': 'photo',
        'targetAudience': 'Photography Enthusiasts',
        'isActive': true,
        'maxDuration': 0,
        'entriesCount': 198,
        'prizePool': '₹25,000',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var c in challenges) {
      await collection.add(c);
    }
    print('✅ ${challenges.length} challenges added');
  }

  static Future<void> seedEpisodes() async {
    final collection = _db.collection('episodes');
    final existing = await collection.limit(2).get();
    if (existing.docs.length >= 2) return;

    final episodes = [
      {
        'title': 'Iconic Bollywood Scene',
        'description': 'Recreate the most iconic Bollywood movie scenes. From DDLJ to Sholay - show us your version!',
        'imageUrl': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
        'category': 'Movies',
        'difficulty': 'Medium',
        'mediaType': 'video',
        'isActive': true,
        'entriesCount': 456,
        'likes': 2340,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'K-Drama Moment',
        'description': 'Love K-Dramas? Recreate those heart-fluttering moments from your favorite Korean series.',
        'imageUrl': 'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?w=800',
        'category': 'TV Series',
        'difficulty': 'Easy',
        'mediaType': 'video',
        'isActive': true,
        'entriesCount': 389,
        'likes': 1890,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Anime Cosplay',
        'description': 'Transform into your favorite anime character. Cosplay, poses, and signature moves welcome!',
        'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'category': 'Anime',
        'difficulty': 'Hard',
        'mediaType': 'photo_video',
        'isActive': true,
        'entriesCount': 567,
        'likes': 3210,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Music Video Recreation',
        'description': 'Pick any music video and make it your own. Lip-sync, dance, or create your own version!',
        'imageUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
        'category': 'Music',
        'difficulty': 'Medium',
        'mediaType': 'video',
        'isActive': true,
        'entriesCount': 423,
        'likes': 2100,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Meme Lords',
        'description': 'Bring viral memes to life! Recreate trending memes with your own creative twist.',
        'imageUrl': 'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?w=800',
        'category': 'Memes',
        'difficulty': 'Easy',
        'mediaType': 'photo_video',
        'isActive': true,
        'entriesCount': 678,
        'likes': 4500,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Stand-Up Act',
        'description': 'Got jokes? Perform your best 60-second stand-up comedy routine!',
        'imageUrl': 'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=800',
        'category': 'Comedy',
        'difficulty': 'Hard',
        'mediaType': 'video',
        'isActive': true,
        'entriesCount': 234,
        'likes': 1560,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var e in episodes) {
      await collection.add(e);
    }
    print('✅ ${episodes.length} episodes added');
  }

  static Future<void> seedChapters() async {
    final collection = _db.collection('chapters');
    final existing = await collection.limit(2).get();
    if (existing.docs.length >= 2) return;

    final chapters = [
      {
        'title': 'My City Story',
        'description': 'Tell us about your city - its hidden gems, local legends, and what makes it special.',
        'imageUrl': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=800',
        'category': 'Places',
        'mediaType': 'audio',
        'maxDuration': 180,
        'isActive': true,
        'entriesCount': 156,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Childhood Memories',
        'description': 'Share a favorite childhood memory - the games, the friends, the innocent times.',
        'imageUrl': 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=800',
        'category': 'Personal',
        'mediaType': 'audio',
        'maxDuration': 180,
        'isActive': true,
        'entriesCount': 234,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Local Legends',
        'description': 'Every place has stories. Share folklore, urban legends, or tales passed down generations.',
        'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
        'category': 'Stories',
        'mediaType': 'audio',
        'maxDuration': 180,
        'isActive': true,
        'entriesCount': 89,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Life Lessons',
        'description': 'Share a life lesson you learned the hard way. Your experience could help someone.',
        'imageUrl': 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=800',
        'category': 'Wisdom',
        'mediaType': 'audio',
        'maxDuration': 180,
        'isActive': true,
        'entriesCount': 312,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var ch in chapters) {
      await collection.add(ch);
    }
    print('✅ ${chapters.length} chapters added');
  }
}
