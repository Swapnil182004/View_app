import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/course/data/models/course_model.dart';
import 'package:online_course/src/features/course/data/models/cur.model.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/course_detail.dart';
import 'package:online_course/src/widgets/custom_image.dart';

class MyCourseItem extends StatefulWidget {
  const MyCourseItem({
    required this.course_user_data,
    Key? key,
    this.progressColor,
    this.completedPercent = 0.0,
  }) : super(key: key);
  
  final course_user_relation course_user_data;
  final Color? progressColor;
  final double completedPercent;

  @override
  State<MyCourseItem> createState() => _MyCourseItemState();
}

class _MyCourseItemState extends State<MyCourseItem> {
  CourseModel? data;

  @override
  void initState() {
    super.initState();
    fetchCourseData();
  }

  void fetchCourseData() {
    FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.course_user_data.courseId.toString())
        .get()
        .then((doc) {
      data = CourseModel.fromMap(doc.data() ?? {});
      print(doc.data());
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA), // ✅ Off-white surface
          borderRadius: BorderRadius.circular(12), // ✅ 12dp rounded
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1A56DB), // 🔵 Brand Blue
          ),
        ),
      );
    }
    
    return GestureDetector(
      onTap: () async {
        AppNavigator.to(
          context,
          CourseDetailPage(
            course: data!,
            isPurchased: true,
            purchasedType: const [0],
            purchasedSections: widget.course_user_data.sections,
            sectionPurchaseDate: widget.course_user_data.sectionPurchaseDate, initialTab: 3,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // ✅ 12dp rounded for cards
          color: Colors.white, // ✅ Pure white card
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildCourseInfo(),
      ),
    );
  }

  Widget _buildCourseInfo() {
    final effectiveProgressColor = widget.progressColor ?? const Color(0xFF1A56DB); // 🔵 Blue default
    
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE8ECF9), // ✅ Light emerald
                  Color(0xFFFFF9E6), // ✅ Light golden
                ],
              ),
            ),
            child: CustomImage(
              data?.image ?? "",
              radius: 10,
              height: 70,
              width: 70,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data?.name ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A), // ✅ Dark text
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFF1A56DB), // 🔵 Brand Blue
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Purchased",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575), // ✅ Secondary text
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: effectiveProgressColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 1.0,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1A56DB), // 🔵 Brand Blue
                              Color(0xFF5A81E8), // ✅ Light Emerald
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF1A56DB), // 🔵 Brand Blue
          ),
        ],
      ),
    );
  }

  Future<Map<int, List<int>>> fetchMapFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('mycourses')) {
        Map<String, dynamic> myCoursesMap =
            data['mycourses'] as Map<String, dynamic>;

        Map<int, List<int>> resultMap = {};
        myCoursesMap.forEach((key, value) {
          int intKey = int.parse(key);
          List<int> intListValue = List<int>.from(value as List<dynamic>);
          resultMap[intKey] = intListValue;
        });

        return resultMap;
      } else {
        print('Field "mycourses" not found or not in the expected format');
        return {};
      }
    } catch (e) {
      print('Error fetching data: $e');
      return {};
    }
  }
}
