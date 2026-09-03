import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your step provider here
import '../../../../core/services/local_storage_service.dart';
import '../../../step_tracking/presentation/providers/step_provider.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref,
  );
});

class AuthController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Ref _ref;

  AuthController(this._auth, this._firestore, this._ref);

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    // This pulls data into Hive immediately after successful login
    await _ref.read(stepNotifierProvider.notifier).restoreDataFromFirebase();
  }

  Future<void> signUp(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      final displayName = email.split('@').first;

      await _firestore.collection('users').doc(user.uid).set({
        'name': displayName,
        'displayName': displayName,
        'totalSteps': 0,
        'photoUrl': '',
        'avatarUrl': '🙂',
      });

      await user.updateDisplayName(displayName);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();

    final storage = LocalStorageService();
    await storage.init();
    await storage.clearAllUserData();
  }
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}