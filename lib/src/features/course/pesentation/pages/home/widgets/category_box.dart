import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryBox extends StatelessWidget {
  const CategoryBox({
    Key? key,
    required this.data,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
  }) : super(key: key);

  final Map data;
  final Color? selectedColor;
  final bool isSelected;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: data["name"],
      child: Tooltip(
        message: data["name"],
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedIcon(context),
                const SizedBox(height: 8),
                _buildName(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      data["name"],
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isSelected ? cs.primary : cs.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  Widget _buildAnimatedIcon(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveSelectedColor = selectedColor ?? cs.primary;
    final iconPath = data["icon"] as String;
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? cs.primaryContainer : cs.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? cs.primary.withOpacity(0.25)
                : cs.shadow.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: isSvg
          ? SvgPicture.asset(
              iconPath,
              width: 36,
              height: 36,
              colorFilter: ColorFilter.mode(
                isSelected ? effectiveSelectedColor : cs.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            )
          : Image.asset(
              iconPath,
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
    );
  }
}
