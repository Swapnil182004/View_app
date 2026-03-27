import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:online_course/src/widgets/custom_image.dart';

class FeatureItem extends StatelessWidget {
  const FeatureItem({
    Key? key,
    required this.course,
    this.width = 280,
    this.height = 290,
    this.onTap,
  }) : super(key: key);

  final Course course;
  final double width;
  final double height;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: cs.surface, // ✅ Pure white
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            CustomImage(
              course.image,
              width: double.infinity,
              height: 190,
              radius: 15,
            ),
            Positioned(
              top: 170,
              right: 15,
              child: _buildPrice(context),
            ),
            Positioned(
              top: 210,
              left: 0,
              right: 0,
              child: _buildInfo(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      width: width - 20,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            course.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          _buildAttributes(context),
        ],
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary, // ✅ Emerald green
            cs.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '₹${course.price}',
        style: TextStyle(
          color: cs.onPrimary, // ✅ White text
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildAttributes(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Flexible(
          child: _getAttribute(
            context,
            Icons.play_circle_outlined,
            cs.primary, // ✅ Emerald
            course.session,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _getAttribute(
            context,
            Icons.schedule_rounded,
            cs.secondary, // ✅ Golden
            course.duration,
          ),
        ),
        const SizedBox(width: 8),
        _getAttribute(
          context,
          Icons.star,
          cs.secondary, // ✅ Golden for rating
          course.review,
        ),
      ],
    );
  }

  Widget _getAttribute(BuildContext context, IconData icon, Color color, String info) {
    final cs = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            info,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
