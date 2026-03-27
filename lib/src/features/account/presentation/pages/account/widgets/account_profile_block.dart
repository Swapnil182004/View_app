import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_course/core/services/auth_service.dart';
import 'package:online_course/src/widgets/custom_image.dart';

class AccountProfileBlock extends StatelessWidget {
  AccountProfileBlock({required this.profile, super.key});
  
  final Map profile;
  final User? user = AuthService().user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.05),
            cs.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: CustomImage(
                user?.photoURL ??
                    'https://cdn.vectorstock.com/i/1000v/51/90/student-avatar-user-profile-icon-vector-47025190.jpg',
                width: 80,
                height: 80,
                radius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Student',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface, // ✅ Theme-driven
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant, // ✅ Theme-driven
            ),
          ),
        ],
      ),
    );
  }
}
