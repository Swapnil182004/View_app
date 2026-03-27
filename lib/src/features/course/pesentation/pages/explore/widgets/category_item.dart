import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    Key? key,
    required this.data,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);
  
  final Map data;
  final bool isSelected;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF1A56DB), // 🔵 Brand Blue
                    Color(0xFF5A81E8), // ✅ Light Emerald
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFFF5F5F5), // ✅ Light gray when unselected
          borderRadius: BorderRadius.circular(10), // ✅ 10dp rounded
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF1A56DB).withOpacity(0.3)
                  : Colors.black.withOpacity(0.03),
              spreadRadius: 0,
              blurRadius: isSelected ? 8 : 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              data["icon"],
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : const Color(0xFF757575), // ✅ Theme-driven
                BlendMode.srcIn,
              ),
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 7),
            Text(
              data["name"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF757575), // ✅ Theme-driven
              ),
            )
          ],
        ),
      ),
    );
  }
}
