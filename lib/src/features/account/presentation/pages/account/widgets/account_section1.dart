import 'package:flutter/material.dart';
import 'package:online_course/src/features/account/presentation/pages/account/widgets/setting_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountBlock1 extends StatelessWidget {
  const AccountBlock1({super.key});

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
            title: "Official channel",
            leadingIcon: "assets/icons/logo_yt.svg",
            bgIconColor: const Color(0xFFFF0000), // YouTube Red
            onTap: () {
              launchUrl(Uri.parse('https://www.youtube.com/@examplanb'));
            },
          ),
          Divider(height: 1, color: cs.outlineVariant),
          SettingItem(
            title: "Follow us",
            leadingIcon: "assets/icons/logo_fb.svg",
            bgIconColor: const Color(0xFF1877F2), // Facebook Blue
            onTap: () {
              launchUrl(
                  Uri.parse('https://www.facebook.com/share/14SnoXteSU8/'));
            },
          ),
          Divider(height: 1, color: cs.outlineVariant),
          SettingItem(
            title: "Instagram page",
            leadingIcon: "assets/icons/logo_ig.svg",
            bgIconColor: const Color(0xFFE4405F), // Instagram Pink
            onTap: () {
              launchUrl(Uri.parse('https://www.instagram.com/view41674'));
            },
          ),
          Divider(height: 1, color: cs.outlineVariant),
          SettingItem(
            title: "Telegram",
            leadingIcon: "assets/icons/logo_telegram.svg",
            bgIconColor: const Color(0xFF0088CC), // Telegram Blue
            onTap: () {
              launchUrl(Uri.parse('https://telegram.me/examplanbofficials'));
            },
          ),
          Divider(height: 1, color: cs.outlineVariant),
          SettingItem(
            title: "Channel",
            leadingIcon: "assets/icons/locn_whatsapp.svg",
            bgIconColor: const Color(0xFF25D366), // WhatsApp Green
            onTap: () {
              launchUrl(Uri.parse('https://wa.link/6zxsq2'));
            },
          ),
        ],
      ),
    );
  }
}
