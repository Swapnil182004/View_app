import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:online_course/src/features/course/pesentation/bloc/favorite_course/favorite_course_bloc.dart';
import 'package:online_course/src/widgets/favorite_box_v2.dart';

class CourseDetailInfo extends StatefulWidget {
  const CourseDetailInfo({required this.course, super.key});

  final Course course;

  @override
  State<CourseDetailInfo> createState() => _CourseDetailInfoState();
}

class _CourseDetailInfoState extends State<CourseDetailInfo> {
  bool showDescription = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 TITLE + FAVORITE
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.course.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(width: 12),
            BlocBuilder<FavoriteCourseBloc, FavoriteCourseState>(
              builder: (context, state) {
                return FavoriteBoxV2(
                  isFavorited: widget.course.isFavorited,
                  onTap: () {
                    context
                        .read<FavoriteCourseBloc>()
                        .add(ToggleFavoriteCourse(widget.course));
                  },
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// 🔹 COURSE META INFO - Emerald & Golden
        Row(
          children: [
            Expanded(
              child: _buildCourseAttribute(
                context,
                Icons.play_circle_outline,
                const Color(0xFF1A56DB), // ✅ Emerald Green
                widget.course.session,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCourseAttribute(
                context,
                Icons.schedule_rounded,
                const Color(0xFF1D4ED8), // 🔵 Standard Blue
                widget.course.duration,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCourseAttribute(
                context,
                Icons.star,
                const Color(0xFFF0A500), // ✅ Darker Golden
                widget.course.review,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // About Course Title
        const Text(
          "About Course",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 12),

        // Description
        if (showDescription)
          MarkdownBody(
            data: _decodeDescription(widget.course.description),
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 15,
                height: 1.6,
              ),
              strong: const TextStyle(
                color: Color(0xFF1A56DB), // ✅ Emerald for emphasis
                fontWeight: FontWeight.bold,
              ),
              h1: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              h2: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),

        if (!showDescription)
          Text(
            _decodeDescription(widget.course.description).length > 200
                ? '${_decodeDescription(widget.course.description).substring(0, 200)}...'
                : _decodeDescription(widget.course.description),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF424242),
              height: 1.6,
            ),
          ),

        // Show More/Less Button
        TextButton(
          onPressed: () {
            setState(() {
              showDescription = !showDescription;
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showDescription ? "Show less" : "Show more",
                style: const TextStyle(
                  color: Color(0xFF1A56DB), // ✅ Emerald Green
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                showDescription
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF1A56DB), // ✅ Emerald Green
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔹 SAFE BASE64 DECODE
  String _decodeDescription(String description) {
    try {
      return utf8.decode(base64.decode(description));
    } catch (_) {
      return description;
    }
  }

  /// 🔹 COURSE ATTRIBUTE ITEM - Clean White Cards with Border
  Widget _buildCourseAttribute(
    BuildContext context,
    IconData icon,
    Color color,
    String info,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              info,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
