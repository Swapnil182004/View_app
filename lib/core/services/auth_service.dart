import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  User? user = FirebaseAuth.instance.currentUser;

  static User? getUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> signOutUser(VoidCallback onSignOut) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      onSignOut();
      if (kDebugMode) {
        print("User signed out successfully.");
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error signing out: $error");
      }
    }
  }

  Future<User?> signInwithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      if (kIsWeb) {
        // Web sign-in
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await auth.signInWithPopup(authProvider);
      } else {
        // Mobile sign-in
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: <String>['email'],
        );

        // Sign out first to ensure account picker shows
        await googleSignIn.signOut();

        // This will show the Google account picker
        final GoogleSignInAccount? googleSignInAccount =
            await googleSignIn.signIn();

        // If user cancels, return null
        if (googleSignInAccount == null) {
          if (kDebugMode) {
            print('User cancelled Google Sign-In');
          }
          return null;
        }

        // Get authentication details
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // Create Firebase credential with null checks
        final String? accessToken = googleSignInAuthentication.accessToken;
        final String? idToken = googleSignInAuthentication.idToken;

        if (accessToken == null || idToken == null) {
          if (kDebugMode) {
            print('Missing Google Sign-In tokens');
          }
          return null;
        }

        // Create Firebase credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );

        // Sign in to Firebase
        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          user = userCredential.user;

          if (kDebugMode) {
            print('Successfully signed in: ${user?.email}');
          }
        } on FirebaseAuthException catch (e) {
          if (kDebugMode) {
            print('Firebase sign in error: ${e.code} - ${e.message}');
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-In error: $error');
      }
    }

    return auth.currentUser;
  }
}
