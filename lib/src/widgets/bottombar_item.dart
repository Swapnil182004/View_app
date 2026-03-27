import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:math' as math;

class BottomBarItem extends StatefulWidget {
  const BottomBarItem(
    this.icon, {
    super.key,
    this.onTap,
    this.color = const Color(0xFF424242), // Dark gray/black for icons
    this.activeColor = const Color(0xFF1A56DB), // Emerald green for active
    this.isActive = false,
    this.isNotified = false,
    required this.title,
  });

  final String title;
  final String icon;
  final Color color;
  final Color activeColor;
  final bool isNotified;
  final bool isActive;
  final GestureTapCallback? onTap;

  @override
  State<BottomBarItem> createState() => _BottomBarItemState();
}

class _BottomBarItemState extends State<BottomBarItem> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Speed of the moving shadow
    );
    if (widget.isActive) {
      _glowController.repeat();
    }
  }

  @override
  void didUpdateWidget(BottomBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _glowController.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _glowController.stop();
      _glowController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSvg = widget.icon.toLowerCase().endsWith('.svg');

    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Static Icon background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive 
                      ? Colors.white.withOpacity(0.25) 
                      : const Color(0xFFFAFAFA),
                ),
                child: isSvg
                    ? SvgPicture.asset(
                        widget.icon,
                        colorFilter: ColorFilter.mode(
                          widget.isActive ? widget.activeColor : widget.color,
                          BlendMode.srcIn,
                        ),
                        width: 22,
                        height: 22,
                      )
                    : Image.asset(
                        widget.icon,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                        color: widget.isActive ? widget.activeColor : widget.color,
                      ),
              ),
              
              const SizedBox(height: 6),
              
              // Label text
              Flexible(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.isActive ? widget.activeColor : widget.color,
                    fontSize: 11,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// LIGHT GREEN BOTTOM NAVIGATION BAR
// ========================================
class LightGreenBottomNavBar extends StatelessWidget {
  final List<BottomBarItem> items;
  final int currentIndex;

  const LightGreenBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 20, // Space from system nav bar
      ),
      height: 72, // Fixed height
      decoration: BoxDecoration(
        // Light green background
        color: const Color(0xFFE8ECF9), // Light emerald green from your theme
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items,
        ),
      ),
    );
  }
}
