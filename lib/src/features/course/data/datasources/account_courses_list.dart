import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:online_course/src/features/course/data/models/course_model.dart';
import 'package:online_course/src/features/course/data/models/cur.model.dart';

Future<List<CourseModel>> fetchMyCourses() async {
  User? Fireba = FirebaseAuth.instance.currentUser;
  final purchasedCoursesSnapshot = await FirebaseFirestore.instance
      .collection('user_course_relation')
      .where('userId', isEqualTo: Fireba?.uid ?? "me")
      .orderBy('purchase_date')
      .get();
  List<course_user_relation> courseUserRelations = [];
  for (var doc in purchasedCoursesSnapshot.docs) {
    courseUserRelations.add(course_user_relation.fromJson(doc.data()));
  }



  try {
    // Get the Firestore document with the ID "me"
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Fireba?.uid ?? "me")
        .get();

    // Check if the document exists
    if (snapshot.exists) {
      // Access the "nestedArray" field which contains arrays
      List<dynamic> nestedArray = snapshot.get('courses');

      // Now you have the specific field from the first array, you can use it as needed
      List<CourseModel> myCourses = [];

      CollectionReference reference =
          FirebaseFirestore.instance.collection('courses');
      // ignore: avoid_function_literals_in_foreach_calls
      for (var element in nestedArray) {
        DocumentSnapshot courseSnapshot = await reference
            .where('id', isEqualTo: element)
            .get()
            .then((value) => value.docs[0]);
        Map<String, dynamic> courseData =
            courseSnapshot.data() as Map<String, dynamic>;
        CourseModel courseModel = CourseModel.fromMap(courseData);
        myCourses.add(courseModel);
      }
      return myCourses;
    } else {
      return [];
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching data: $e');
    }
    return [];
  }
}

// Future<int> addCourseToAccount(int id, List<int> selectedForPayment) async {
//   User? Fireba = FirebaseAuth.instance.currentUser;
//   try {
//     var userDoc = FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser?.uid ?? "me");

//     var userSnapshot = await userDoc.get();

//     if (!userSnapshot.exists) {
//       // Create the document with the initial structure
//       await userDoc.set({'courses': [id],'mycourses': {id.toString(): selectedForPayment}}, SetOptions(merge: true));

//       return 200;
//     }

//     // Map<String, dynamic> coursesMap = {
//     //   id.toString(): FieldValue.arrayUnion(selectedForPayment)
//     // };

//     // await FirebaseFirestore.instance
//     //     .collection('users')
//     //     .doc(Fireba?.uid ?? "me")
//     //     .update({
//     //   'courses': FieldValue.arrayUnion([id]),
//     //   'mycourses.$id': FieldValue.arrayUnion(selectedForPayment)
//     // });
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser?.uid ?? "me")
//         .set({
//       'courses': FieldValue.arrayUnion([id]),
//       'mycourses.$id': FieldValue.arrayUnion(selectedForPayment)
//     }, SetOptions(merge: true));

//     return 200;
//   } catch (e) {
//     // try {
//     //   await FirebaseFirestore.instance
//     //       .collection('users')
//     //       .doc(Fireba?.uid ?? "me")
//     //       .set({
//     //     'courses': FieldValue.arrayUnion([id]),
//     //     'mycourses': {id.toString(): selectedForPayment}
//     //   });
//     //   return 200;
//     // } catch (e) {
//     return 400;
//     // }
//   }

// }

// Method to add or update a course
Future<int> addOrUpdateCourse(
    int courseId, List<String> sectionIdsforPayment) async {
  try {
    Map<String, Timestamp> sectionsMap = {};
    for (String sectionId in sectionIdsforPayment) {
      sectionsMap[sectionId] = Timestamp.now();
    }
    await FirebaseFirestore.instance
        .collection('user_course_relation')
        .doc('$courseId${FirebaseAuth.instance.currentUser?.uid ?? "me"}')
        .set({
      'courseId': courseId,
      'userId': FirebaseAuth.instance.currentUser?.uid ?? "me",
      'sections': FieldValue.arrayUnion(sectionIdsforPayment),
      'sectionPurchaseDate': sectionsMap,
      'purchase_date': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return 200;

    // try {
    //   DocumentReference userDoc = FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(FirebaseAuth.instance.currentUser?.uid ?? "me");
    //   DocumentSnapshot userSnapshot = await userDoc.get();

    //   if (userSnapshot.exists) {
    //     Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
    //     if (data.containsKey('mycourses')) {
    //       Map<String, dynamic> myCourses =
    //           Map<String, dynamic>.from(data['mycourses']);

    //       if (myCourses.containsKey(courseId.toString())) {
    //         List<int> existingSections =
    //             List<int>.from(myCourses[courseId.toString()]);
    //         for (int section in newSections) {
    //           if (!existingSections.contains(section)) {
    //             existingSections.add(section);
    //           }
    //         }
    //         existingSections.sort();
    //         myCourses[courseId.toString()] = existingSections;
    //       } else {
    //         myCourses[courseId.toString()] = newSections;
    //       }
    //       await userDoc.update({
    //         'courses': FieldValue.arrayUnion([courseId]),
    //         'mycourses': myCourses
    //       });
    //       return 200;
    //     } else {
    //       await userDoc.set({
    //         'courses': FieldValue.arrayUnion([courseId]),
    //         'mycourses': {
    //           courseId.toString(): newSections,
    //         }
    //       }, SetOptions(merge: true));
    //       return 200;
    //     }
    //   } else {
    //     await userDoc.set({
    //       'courses': FieldValue.arrayUnion([courseId]),
    //       'mycourses': {
    //         courseId.toString(): newSections,
    //       }
    //     });
    //     return 200;
    //   }
  } catch (e) {
    return 400;
  }
}
