import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppAuthProvider extends ChangeNotifier {
  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }

  User? get user => FirebaseAuth.instance.currentUser;
  bool get isSignedIn => user != null;

  String get displayName {
    final u = user;
    if (u == null) return 'Guest';
    if (u.displayName != null && u.displayName!.isNotEmpty) return u.displayName!;
    return u.email?.split('@').first ?? 'Guest';
  }

  String get email => user?.email ?? '';

  Future<void> signOut() => FirebaseAuth.instance.signOut();
}
