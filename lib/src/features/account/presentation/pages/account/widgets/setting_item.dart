import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    Key? key,
    required this.title,
    this.onTap,
    this.leadingIcon,
    this.leadingIconColor = Colors.white,
    this.bgIconColor,
  }) : super(key: key);

  final String? leadingIcon;
  final Color leadingIconColor;
  final Color? bgIconColor;
  final String title;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: leadingIcon != null ? _buildItemWithPrefixIcon(context) : _buildItem(context),
      ),
    );
  }

  Widget _buildPrefixIcon(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveBgColor = bgIconColor ?? cs.primary;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        leadingIcon!,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          leadingIconColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildItemWithPrefixIcon(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPrefixIcon(context),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: cs.onSurface, // ✅ Theme-driven
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          color: cs.onSurfaceVariant, // ✅ Theme-driven
          size: 16,
        )
      ],
    );
  }

  Widget _buildItem(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface, // ✅ Theme-driven
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          color: cs.onSurfaceVariant, // ✅ Theme-driven
          size: 16,
        )
      ],
    );
  }
}
