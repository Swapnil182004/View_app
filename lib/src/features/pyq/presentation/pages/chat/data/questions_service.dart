import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:online_course/core/services/fast_search_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> getExams(
      String searchedText, String selectedCategory) async {
    QuerySnapshot snapshot;
    if (searchedText.isNotEmpty) {
      try {
        var docIds = await getDocIdsBySearchTerm(searchedText, 'pyq');

        if (docIds.isNotEmpty) {
          snapshot = await _db
              .collection('previous_year_questions')
              .where(FieldPath.documentId, whereIn: docIds)
              .get();
        } else {
          snapshot = await _db.collection('previous_year_questions').get();
        }
      } catch (e) {
        if (kDebugMode) {
          print('search error $e');
        }
        snapshot = await _db.collection('previous_year_questions').get();
      }
    } else if (selectedCategory.isNotEmpty) {
      if (selectedCategory == 'All') {
        snapshot = await _db.collection('previous_year_questions').get();
      } else {
        snapshot = await _db
          .collection('previous_year_questions')
          .where('tags', arrayContains: selectedCategory)
          .get();
      }
      
    } else {
      snapshot = await _db.collection('previous_year_questions').get();
    }

    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getYears(String examId) async {
    QuerySnapshot snapshot = await _db
        .collection('previous_year_questions')
        .doc(examId)
        .collection('years')
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getQuestions(
      String examId, String yearId) async {
    QuerySnapshot snapshot = await _db
        .collection('previous_year_questions')
        .doc(examId)
        .collection('years')
        .doc(yearId)
        .collection('questions')
        .get();
    return snapshot.docs;
  }
}
