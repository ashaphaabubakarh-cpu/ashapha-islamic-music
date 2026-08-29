import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'isAdmin': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return cred;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Checks the `isAdmin` flag on the user's Firestore doc.
  /// Set this to `true` manually in the Firebase Console for admin accounts.
  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    return (doc.data()?['isAdmin'] ?? false) as bool;
  }
}
