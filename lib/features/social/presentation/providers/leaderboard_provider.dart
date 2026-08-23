import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardUser {
  final String id;
  final String name;
  final int totalSteps;
  final String avatarUrl;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.totalSteps,
    required this.avatarUrl,
  });

  factory LeaderboardUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardUser(
      id: doc.id,
      name: data['name'] ?? 'Anonymous Walker',
      totalSteps: data['totalSteps'] ?? 0,
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}

final leaderboardProvider = StreamProvider<List<LeaderboardUser>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('totalSteps', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => LeaderboardUser.fromDocument(doc)).toList();
  });
});