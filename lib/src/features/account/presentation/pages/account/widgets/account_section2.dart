import 'package:flutter/material.dart';
import 'package:online_course/src/features/account/presentation/pages/account/widgets/setting_item.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountBlock2 extends StatelessWidget {
  const AccountBlock2({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surface, // ✅ Theme surface
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SettingItem(
            title: "Official Website",
            leadingIcon: "assets/icons/discover.svg",
            bgIconColor: cs.primary, // ✅ VIEW Green/Purple
            onTap: () {
              launchUrl(Uri.parse("http://viewinstitute.com/"));
            },
          ),
          Divider(height: 1, color: cs.outlineVariant),
          SettingItem(
            title: "Privacy Policy",
            leadingIcon: "assets/icons/shield.svg",
            bgIconColor: cs.secondary, // ✅ VIEW Cyan
            onTap: () {
              launchUrl(Uri.parse("http://viewinstitute.com/privacy"));
            },
          ),
          Divider(height: 1, color: cs.outlineVariant),
          SettingItem(
            title: "Return and refund",
            leadingIcon: "assets/icons/bell.svg",
            bgIconColor: const Color(0xFFE67E22), // Orange
            onTap: () {
              launchUrl(Uri.parse(
                  "http://viewinstitute.com/privacy")); // Pointing to privacy as per user request for domain update
            },
          ),
        ],
      ),
    );
  }
}
