import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/leaderboard_user.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final leaderboardStreamProvider = StreamProvider<List<LeaderboardUser>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('users')
      .orderBy('totalSteps', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return LeaderboardUser.fromFirestore(doc.data(), doc.id);
    }).toList();
  });
});