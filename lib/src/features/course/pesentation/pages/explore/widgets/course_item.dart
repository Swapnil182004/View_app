import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_course/core/utils/app_util.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:online_course/src/features/course/pesentation/bloc/favorite_course/favorite_course_bloc.dart';
import 'package:online_course/src/widgets/custom_image.dart';
import 'package:online_course/src/widgets/favorite_box_v2.dart';

class CourseItem extends StatelessWidget {
  const CourseItem({
    Key? key,
    required this.course,
    this.onTap,
    this.width = 200,
    this.height = 290,
  }) : super(key: key);

  final Course course;
  final double width;
  final double height;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 5, top: 5),
        decoration: BoxDecoration(
          color: Colors.white, // ✅ Pure white card
          borderRadius: BorderRadius.circular(12), // ✅ 12dp rounded
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildCourseImage(),
            Positioned(
              top: 170,
              right: 15,
              child: _buildFavoriteButton(),
            ),
            Positioned(
              top: 210,
              left: 0,
              right: 0,
              child: _buildCourseInfo(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return BlocConsumer<FavoriteCourseBloc, FavoriteCourseState>(
      listener: (context, state) {
        if (state is FavoiriteCourseError) {
          AppUtil.showSnackbar(
            context: context,
            message: "Something went wrong.",
          );
        }
      },
      buildWhen: (previous, current) {
        return current is FavoiriteCourseLoaded &&
            current.course.id == course.id;
      },
      builder: (context, state) {
        return FavoriteBoxV2(
          isFavorited: course.isFavorited,
          onTap: () {
            BlocProvider.of<FavoriteCourseBloc>(context)
                .add(ToggleFavoriteCourse(course));
          },
        );
      },
    );
  }

  Widget _buildCourseInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            course.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A), // ✅ Dark text
            ),
          ),
          const SizedBox(height: 10),
          _buildAttributeBlock(context),
        ],
      ),
    );
  }

  Widget _buildCourseImage() {
    return Hero(
      tag: '${course.id}${course.image}',
      child: CustomImage(
        course.image,
        width: width,
        height: 190,
        radius: 10, // ✅ 10dp rounded
      ),
    );
  }

  Widget _buildAttributeBlock(BuildContext context) {
    return Row(
      children: [
        // Price with emerald/golden gradient
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A56DB), // 🔵 Brand Blue
                Color(0xFF5A81E8), // ✅ Light Emerald
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '₹${course.price}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white, // ✅ White text on green
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Session
        _buildAttribute(
          context,
          Icons.play_circle_outlined,
          const Color(0xFF1D4ED8), // 🔵 Standard Blue
          course.session,
        ),
        const SizedBox(width: 8),

        // Duration - Flexible
        Flexible(
          child: _buildAttribute(
            context,
            Icons.schedule_rounded,
            const Color(0xFF1D4ED8), // 🔵 Standard Blue
            course.duration,
          ),
        ),
        const SizedBox(width: 8),

        // Review
        _buildAttribute(
          context,
          Icons.star,
          const Color(0xFF1D4ED8), // 🔵 Standard Blue for star
          course.review,
        ),
      ],
    );
  }

  Widget _buildAttribute(
    BuildContext context,
    IconData icon,
    Color color,
    String info,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            info,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF757575), // ✅ Secondary text
            ),
          ),
        ),
      ],
    );
  }
}
