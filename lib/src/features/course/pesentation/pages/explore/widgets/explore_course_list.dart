import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:online_course/core/errors/exception.dart';
import 'package:online_course/core/services/fast_search_service.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/course/data/models/course_model.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/course_detail.dart';
import 'package:online_course/src/features/course/pesentation/pages/explore/widgets/course_item.dart';
import 'package:online_course/src/widgets/custom_progress_indicator.dart';

class ExploreCourseList extends StatefulWidget {
  final String searchText;
  final String selectedCategory;

  const ExploreCourseList({
    super.key,
    required this.searchText,
    required this.selectedCategory,
  });

  @override
  State<ExploreCourseList> createState() => _ExploreCourseListState();
}

class _ExploreCourseListState extends State<ExploreCourseList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Color(0xFFE67E22), // ✅ Orange error
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: const Color(0xFF757575).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try adjusting your search or filters',
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

        List<CourseModel> courses = snapshot.data as List<CourseModel>;
        return _buildItemList(courses);
      },
    );
  }

  Widget _buildItemList(List<Course> courses) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return CourseItem(
          onTap: () {
            AppNavigator.to(
              context,
              CourseDetailPage(
                course: courses[index],
                isHero: true, initialTab: 3,
              ),
            );
          },
          course: courses[index],
          width: MediaQuery.of(context).size.width,
        );
      },
    );
  }

  Future<List<CourseModel>> getCourses() async {
    try {
      List<CourseModel> courseModels = [];
      Query query = FirebaseFirestore.instance.collection('courses');

      if (widget.searchText.isNotEmpty) {
        if (kDebugMode) {
          print('got search text ${widget.searchText}');
        }
        try {
          var docIds = await getDocIdsBySearchTerm(
            widget.searchText.toLowerCase(),
            'course',
          );

          if (docIds.isNotEmpty) {
            query = query.where(FieldPath.documentId, whereIn: docIds);
            if (kDebugMode) {
              print('got docs from search $docIds');
            }
          } else {
            return [];
          }
        } catch (e) {
          if (kDebugMode) {
            print('search error $e');
          }
        }
      } else if (widget.selectedCategory.isNotEmpty &&
          widget.selectedCategory != "All") {
        query = query
            .where('tags', arrayContains: widget.selectedCategory)
            .limit(20);
      } else {
        if (kDebugMode) {
          print('nothing selected or searched');
        }
        query = query.limit(50);
      }

      QuerySnapshot querySnapshot = await query.get();

      for (var courseDoc in querySnapshot.docs) {
        Map<String, dynamic> courseData =
            courseDoc.data() as Map<String, dynamic>;
        CourseModel courseModel = CourseModel.fromMap(courseData);
        courseModels.add(courseModel);
      }

      return courseModels;
    } catch (e) {
      throw ServerException();
    }
  }
}
