import 'package:cloud_firestore/cloud_firestore.dart';

class course_user_relation {
  final String userId;
  final int courseId;
  final List<String> sections;
  final Map<String, Timestamp> sectionPurchaseDate;
  final Timestamp purchaseDate;

  course_user_relation(
      {required this.userId,
      required this.courseId,
      required this.sections,
      required this.sectionPurchaseDate,
      required this.purchaseDate});

  factory course_user_relation.fromJson(Map<String, dynamic> json) {
    print(json);
    return course_user_relation(
        userId: json['userId'] as String,
        courseId: json['courseId'] as int,
        purchaseDate: json['purchase_date'] as Timestamp,
        sectionPurchaseDate: Map<String, Timestamp>.from(
          json['sectionPurchaseDate']??{}
        ),
        sections:List<String>.from(json['sections'] as List<dynamic>));
  }
}
