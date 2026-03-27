import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:online_course/src/widgets/custom_image.dart';

class FavoriteItem extends StatelessWidget {
  const FavoriteItem({
    Key? key,
    required this.course,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  final Course course;
  final GestureTapCallback? onTap;
  final Function(BuildContext)? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // ✅ 12dp rounded
          color: Colors.white, // ✅ Pure white
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // ✅ Match parent
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  key: ValueKey(course.id),
                  flex: 8,
                  onPressed: onDelete,
                  backgroundColor: const Color(0xFFE67E22), // ✅ Orange error (not red!)
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CustomImage(
                    course.image,
                    radius: 10, // ✅ 10dp rounded
                    height: 80,
                    width: 80,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInfo(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1A1A1A), // ✅ Dark text
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '₹${course.price}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1D4ED8), // 🔵 Standard Blue for price
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        _buildDurationAndRate(context),
      ],
    );
  }

  Widget _buildDurationAndRate(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.schedule_rounded,
          color: Color(0xFF1D4ED8), // 🔵 Standard Blue
          size: 14,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            course.duration,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575), // ✅ Secondary text
            ),
          ),
        ),
        const SizedBox(width: 20),
        const Icon(
          Icons.star,
          color: Color(0xFF1D4ED8), // 🔵 Standard Blue for rating
          size: 14,
        ),
        const SizedBox(width: 2),
        Text(
          course.review,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF757575), // ✅ Secondary text
          ),
        )
      ],
    );
  }
}
