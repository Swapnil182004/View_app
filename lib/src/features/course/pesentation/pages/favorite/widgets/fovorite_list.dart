import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:online_course/src/features/course/pesentation/bloc/favorite_course/favorite_course_bloc.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/course_detail.dart';
import 'package:online_course/src/features/course/pesentation/pages/favorite/widgets/favorite_item.dart';

class FavoriteList extends StatelessWidget {
  const FavoriteList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCourseBloc, FavoriteCourseState>(
      builder: (context, state) {
        if (state is FavoiriteCourseLoaded) {
          final courses = context.read<FavoriteCourseBloc>().courses;
          return _buildList(context, courses);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildList(BuildContext context, List<Course> favoritedCourses) {
    if (favoritedCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE8ECF9), // ✅ Light emerald
                      Color(0xFFFFF9E6), // ✅ Light golden
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Color(0xFF1A56DB), // 🔵 Brand Blue
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Favorites Yet",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Start adding courses you love!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return FavoriteItem(
          course: favoritedCourses[index],
          onTap: () {
            AppNavigator.to(
              context,
              CourseDetailPage(course: favoritedCourses[index], initialTab: 3,),
            );
          },
          onDelete: (context) {
            BlocProvider.of<FavoriteCourseBloc>(context)
                .add(RemoveFavoriteCourse(favoritedCourses[index]));
          },
        );
      },
      itemCount: favoritedCourses.length,
    );
  }
}
