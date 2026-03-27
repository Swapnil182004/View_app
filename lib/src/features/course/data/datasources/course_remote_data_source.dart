import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_course/core/errors/exception.dart';
import 'package:online_course/src/features/course/data/models/course_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses();
  Future<List<CourseModel>> getFeaturedCourses();
  Future<List<CourseModel>> getRecommendCourses();
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  CourseRemoteDataSourceImpl();

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      // dummy data
      // return coursesData.map((e) => CourseModel.fromMap(e)).toList();

      // Create an empty list to hold CourseModel instances
      List<CourseModel> courseModels = [];

      // Perform the Firestore query
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .limit(40)
          .get();

      // Iterate over the documents and convert them to CourseModel instances
      for (var courseDoc in querySnapshot.docs) {
        // Extract data from the document
        Map<String, dynamic> courseData =
            courseDoc.data() as Map<String, dynamic>;

        // Create a CourseModel instance from the extracted data
        CourseModel courseModel = CourseModel.fromMap(courseData);

        // Add the CourseModel instance to the list
        courseModels.add(courseModel);
      }

      // Return the list of CourseModel instances
      return courseModels;

      // final result = await http.get(Uri.parse(NetworkUrls.getCourses));
      // if (result.statusCode == 200) {
      //   return CourseMapper.jsonToCourseModelList(result.body);
      // }
      // return [];
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<CourseModel>> getFeaturedCourses() async {
    //==== Todo: implement the call to real api =====
    try {
      // dummy data
      List<CourseModel> courseModels = [];

      // Perform the Firestore query
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('isFeatured', isEqualTo: true)
          .limit(6)
          .get();

      // Iterate over the documents and convert them to CourseModel instances
      for (var courseDoc in querySnapshot.docs) {
        // Extract data from the document
        Map<String, dynamic> courseData =
            courseDoc.data() as Map<String, dynamic>;

        // Create a CourseModel instance from the extracted data
        CourseModel courseModel = CourseModel.fromMap(courseData);

        // Add the CourseModel instance to the list
        courseModels.add(courseModel);
      }

      // Return the list of CourseModel instances
      return courseModels;
      // return featuresData.map((e) => CourseModel.fromMap(e)).toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<CourseModel>> getRecommendCourses() async {
    //==== Todo: implement the call to real api =====
    try {
      // dummy data
 List<CourseModel> courseModels = [];

      // Perform the Firestore query
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .orderBy('created')
          .limit(6)
          .get();

      // Iterate over the documents and convert them to CourseModel instances
      for (var courseDoc in querySnapshot.docs) {
        // Extract data from the document
        Map<String, dynamic> courseData =
            courseDoc.data() as Map<String, dynamic>;

        // Create a CourseModel instance from the extracted data
        CourseModel courseModel = CourseModel.fromMap(courseData);

        // Add the CourseModel instance to the list
        courseModels.add(courseModel);
      }

      // Return the list of CourseModel instances
      return courseModels;

    } catch (e) {
      throw ServerException();
    }
  }
}
