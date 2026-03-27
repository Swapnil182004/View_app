 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_course/src/features/course/data/models/course_lessons.dart';

Future<List<CourseLessons>> fetchCoursesLessons(int courseId,String type) async {
    try {
      QuerySnapshot snapshot=await  FirebaseFirestore.instance.collection(type).where('courseId', isEqualTo: courseId).get();
      List<CourseLessons> courses = [];
      for (var doc in snapshot.docs) {
        courses.add(CourseLessons.fromJson(doc.data() as Map<String, dynamic>));
      }
      return courses;
    } catch (e) {
     return [];
    }
  }
