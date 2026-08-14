
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(AuthNotifier.new);

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(ref.read(firebaseAuthProvider).currentUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await ref.read(firebaseAuthProvider).signOut();
    state = const AsyncValue.data(null);
  }
}