import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:online_course/src/widgets/custom_image.dart';

class RecommendItem extends StatelessWidget {
  const RecommendItem({
    Key? key,
    required this.data,
    this.onTap,
    this.onPdfTap, // Callback for PDF icon tap
  }) : super(key: key);

  final Course data;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onPdfTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Course Image (clean, no overlay)
            CustomImage(
              data.image,
              radius: 15,
              height: 80,
              width: 80,
            ),
            const SizedBox(width: 10),
            // Details section
            Expanded(child: _buildInfo(context)),
            const SizedBox(width: 8),
            // PDF Icon at extreme right
            _buildPdfIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '₹${data.price}',
            style: TextStyle(
              fontSize: 14,
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        _buildDurationAndRate(context),
      ],
    );
  }

  Widget _buildPdfIcon(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onPdfTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening course materials...'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.secondary, // Golden yellow
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: cs.secondary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.picture_as_pdf,
          size: 20,
          color: cs.onSecondary,
        ),
      ),
    );
  }

  Widget _buildDurationAndRate(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          color: cs.primary,
          size: 14,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            data.duration,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Icon(
          Icons.star,
          color: cs.secondary,
          size: 14,
        ),
        const SizedBox(width: 2),
        Text(
          data.review,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
