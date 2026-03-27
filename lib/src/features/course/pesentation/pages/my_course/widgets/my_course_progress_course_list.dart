import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/cur.model.dart';
import 'package:online_course/src/features/course/pesentation/pages/my_course/widgets/my_course_item.dart';

class MyCourseProgressCourseList extends StatelessWidget {
  const MyCourseProgressCourseList({
    required this.myProgressCourses,
    super.key,
  });
  
  final List<course_user_relation> myProgressCourses;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: List.generate(
            myProgressCourses.length,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: MyCourseItem(
                course_user_data: myProgressCourses[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

