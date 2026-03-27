import 'package:flutter/material.dart';
import 'dart:math' as math;

class RoundedImage extends StatefulWidget {
  final String imageUrl;
  final double borderRadius;
  final double width;
  final double height;

  const RoundedImage({
    super.key,
    required this.imageUrl,
    this.borderRadius = 12.0,
    this.width = 40.0,
    this.height = 40.0,
  });

  @override
  State<RoundedImage> createState() => _RoundedImageState();
}

class _RoundedImageState extends State<RoundedImage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slow, elegant rotation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    // Smooth padding amount for the animated border
    final double borderThickness = 3.5;
    // The final width we need to fill the exact size desired by parent
    final double innerSize = widget.width;
    final double outerSize = innerSize + (borderThickness * 2);

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius + borderThickness),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // This ensures outer corners are perfectly smooth!
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Spinning Gradient filling the outer box
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: Transform.scale(
                    scale: 1.5, // Make gradient square safely cover all rotated corners
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: SweepGradient(
                          colors: [
                            Color(0xFF00E5FF), // Cyanish
                            Color(0xFF1D4ED8), // Bluish
                            Color(0xFF004D40), // Deep Teal
                            Color(0xFF00E5FF), // Loop back
                          ],
                          stops: [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 2. The Inner Profile Image with a smooth mask and white spacer border
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: Colors.white, width: 2.0), // Clean solid gap
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              width: innerSize,
              height: innerSize,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.secondary,
                        cs.secondary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    color: cs.onSecondary,
                    size: innerSize * 0.6,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

