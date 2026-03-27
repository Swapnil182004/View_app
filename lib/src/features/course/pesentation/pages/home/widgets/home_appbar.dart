import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/course/pesentation/pages/home/widgets/rounded_image.dart';
import 'package:online_course/src/features/account/presentation/pages/account/account.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    // ✅ White text for contrast on deeper green AppBar
    const textColor = Color(0xFFFFFFFF);
    const subtitleColor = Color(0xFFE8F5E9);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Profile Picture
        RoundedImage(
          width: 54,
          height: 54,
          imageUrl: user?.photoURL ??
              'https://cdn.vectorstock.com/i/1000v/51/90/student-avatar-user-profile-icon-vector-47025190.jpg',
        ),

        const SizedBox(width: 10),

        // 2. Name & Greetings — dark green text on light green AppBar
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? 'Dear student',
                style: const TextStyle(
                  color: textColor,              // ✅ White for contrast
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                "Welcome Back !",
                style: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // 3. ✅ Call/Support Button
        GestureDetector(
          onTap: () async {
            final Uri url = Uri(scheme: 'tel', path: '9332363566');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.call_outlined,
              color: Colors.white,              // ✅ White icon
              size: 24,
            ),
          ),
        ),

        const SizedBox(width: 4),

        // 4. Account Icon — Green tinted
        GestureDetector(
          onTap: () {
            AppNavigator.to(context, const AccountPage());
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: textColor,                       // ✅ White icon
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
