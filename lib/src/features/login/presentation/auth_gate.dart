import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../onboarding/presentation/syllabus_setup_screen.dart';
import '../../../root_app.dart';
import 'complete_profile_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // We already know the user is logged in because main.dart checked!
    final user = FirebaseAuth.instance.currentUser!;

    // Check their Firestore 'users' document for profile + onboarding status
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnapshot) {

        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1A56DB)),
            ),
          );
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

        // ✅ STEP 1: Check if profile is completed (name + phone saved)
        final bool profileDone = userData?['profileCompleted'] ?? false;
        if (!profileDone) {
          return const CompleteProfileScreen();
        }

        // ✅ STEP 2: Check if onboarding (syllabus setup) is completed
        final bool isComplete = userData?['onboardingComplete'] ?? false;
        if (!isComplete) {
          return StudentOnboardingPage(userId: user.uid);
        }

        // ✅ STEP 3: All good — show the main app
        return const RootApp();
      },
    );
  }
}
