import 'package:flutter/material.dart';
import 'package:online_course/core/services/auth_service.dart';
import 'package:online_course/src/features/account/presentation/pages/account/widgets/setting_item.dart';
import 'package:online_course/src/features/onboarding/presentation/onboarding_screen.dart';

class AccountBlock3 extends StatelessWidget {
  const AccountBlock3({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        // ✅ Show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    AuthService().signOutUser(() {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const OnboardingScreen()),
                        (route) => false,
                      );
                    });
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(color: cs.error),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.errorContainer.withOpacity(0.1), // ✅ Light red background
          border: Border.all(
            color: cs.error.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.error.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SettingItem(
          title: "Log Out",
          leadingIcon: "assets/icons/logout.svg",
          bgIconColor: cs.error, // ✅ Red for logout
        ),
      ),
    );
  }
}
