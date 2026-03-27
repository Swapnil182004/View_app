import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/pesentation/pages/my_course/widgets/my_course_item.dart';

class MyCourseCompleteCourseList extends StatelessWidget {
  const MyCourseCompleteCourseList({
    required this.myCompleteCourses,
    super.key,
  });
  
  final List myCompleteCourses;

  @override
  Widget build(BuildContext context) {
    if (myCompleteCourses.isEmpty) {
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
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Color(0xFF1D4ED8), // 🔵 Deep Blue for achievement
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Completed Courses",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Keep learning to complete your first course!",
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
    
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: List.generate(
            myCompleteCourses.length,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: MyCourseItem(
                course_user_data: myCompleteCourses[index],
                progressColor: const Color(0xFF1D4ED8), // 🔵 Deep Blue for completed
              ),
            ),
          ),
        ),
      ),
    );
  }
}
