// lib/features/quiz/services/quiz_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_course/src/features/course/data/models/quiz_models.dart';
import 'package:flutter/foundation.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // 🟢 NEW: Get current user name for the Admin Panel
  String get _currentUserName => _auth.currentUser?.displayName ?? "Student";

  // ==================== QUIZ OPERATIONS ====================

  /// Fetch all quizzes for a specific exam category
  Future<List<Quiz>> getQuizzesByCategory(String categoryId) async {
    try {
      final normalizedCategoryId = categoryId.toLowerCase().trim();
      final collectionRef = _firestore
          .collection('exams')
          .doc(normalizedCategoryId)
          .collection('quizzes');

      final allDocs = await collectionRef.get();

      if (allDocs.docs.isEmpty && categoryId != normalizedCategoryId) {
        final originalRef = _firestore
            .collection('exams')
            .doc(categoryId)
            .collection('quizzes');
        final originalDocs = await originalRef.get();
        if (originalDocs.docs.isNotEmpty) {
          return originalDocs.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
        }
      }

      if (allDocs.docs.isEmpty) {
        try {
          final rootQuizzesRef = _firestore.collection('quizzes')
              .where('categoryId', isEqualTo: categoryId);
          final rootDocs = await rootQuizzesRef.get();
          if (rootDocs.docs.isNotEmpty) {
            return rootDocs.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
          }
        } catch (e) {
          debugPrint('Root collection query failed: $e');
        }
      }

      if (allDocs.docs.isEmpty) return [];

      try {
        final filteredQuery = await collectionRef
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();

        return filteredQuery.docs
            .map((doc) => Quiz.fromFirestore(doc))
            .toList();
      } catch (filterError) {
        return allDocs.docs
            .map((doc) => Quiz.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      debugPrint('Error in getQuizzesByCategory: $e');
      return [];
    }
  }

  /// Enrich quizzes with user's attempt history
  Future<List<Quiz>> _enrichQuizzesWithUserData(List<Quiz> quizzes) async {
    final enrichedQuizzes = <Quiz>[];
    for (var quiz in quizzes) {
      final attempts = await getUserQuizAttempts(quiz.id);
      if (attempts.isNotEmpty) {
        final bestAttempt = attempts.reduce((a, b) =>
        a.percentage > b.percentage ? a : b
        );
        enrichedQuizzes.add(quiz.copyWith(
          bestScore: bestAttempt.percentage.round(),
          isCompleted: true,
          lastAttempted: bestAttempt.endTime ?? bestAttempt.startTime,
        ));
      } else {
        enrichedQuizzes.add(quiz);
      }
    }
    return enrichedQuizzes;
  }

  /// Get a single quiz by ID
  Future<Quiz?> getQuizById(String categoryId, String quizId) async {
    try {
      final doc = await _firestore
          .collection('exams')
          .doc(categoryId)
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (doc.exists) return Quiz.fromFirestore(doc);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== QUESTION OPERATIONS ====================

  /// Fetch all questions for a quiz
  Future<List<Question>> getQuizQuestions(String categoryId, String quizId) async {
    try {
      final normalizedCategoryId = categoryId.toLowerCase().trim();
      final questionsRef = _firestore
          .collection('exams')
          .doc(normalizedCategoryId)
          .collection('quizzes')
          .doc(quizId)
          .collection('questions');

      var querySnapshot = await questionsRef.get();

      if (querySnapshot.docs.isEmpty && categoryId != normalizedCategoryId) {
        final originalRef = _firestore
            .collection('exams')
            .doc(categoryId)
            .collection('quizzes')
            .doc(quizId)
            .collection('questions');
        querySnapshot = await originalRef.get();
      }

      if (querySnapshot.docs.isEmpty) return [];

      final questions = querySnapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();

      questions.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return questions;
    } catch (e) {
      return [];
    }
  }

  // ==================== ATTEMPT OPERATIONS (UPDATED) ====================

  /// Start a new quiz attempt (Saves to User folder AND Admin Folder)
  Future<String?> startQuizAttempt(Quiz quiz) async {
    if (currentUserId == null) return null;

    try {
      // Create a unique ID that matches across both collections
      final attemptId = _firestore.collection('quiz_attempts').doc().id;

      final attempt = QuizAttempt(
        id: attemptId,
        quizId: quiz.id,
        quizTitle: quiz.title, // 🟢 Fix: Title now sent
        userId: currentUserId!,
        userName: _currentUserName, // 🟢 Fix: Name now sent
        startTime: DateTime.now(),
        totalQuestions: quiz.totalQuestions,
        totalMarks: quiz.maxMarks,
        answers: {},
        warningCount: 0,
      );

      final data = attempt.toJson();

      // 1. Save to Top-Level Admin Collection
      await _firestore
          .collection('quiz_attempts')
          .doc(attemptId)
          .set({
        ...data,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // 2. Save to User's private history
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('quiz_attempts')
          .doc(attemptId)
          .set(data);

      return attemptId;
    } catch (e) {
      debugPrint('Error starting quiz attempt: $e');
      return null;
    }
  }

  /// Submit quiz attempt (Updates User folder AND Admin Folder)
  Future<bool> submitQuizAttempt(QuizAttempt attempt) async {
    if (currentUserId == null) return false;

    try {
      final updateData = {
        ...attempt.toJson(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // 1. Update Admin-visible record (Changes Live -> Done)
      await _firestore
          .collection('quiz_attempts')
          .doc(attempt.id)
          .set(updateData, SetOptions(merge: true));

      // 2. Update User's private record
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('quiz_attempts')
          .doc(attempt.id)
          .set(updateData, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Error submitting quiz attempt: $e');
      return false;
    }
  }

  /// Get user's attempts for a specific quiz
  Future<List<QuizAttempt>> getUserQuizAttempts(String quizId) async {
    if (currentUserId == null) return [];
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('quiz_attempts')
          .where('quizId', isEqualTo: quizId)
          .where('isCompleted', isEqualTo: true)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => QuizAttempt.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all user's quiz attempts
  Future<List<QuizAttempt>> getAllUserAttempts() async {
    if (currentUserId == null) return [];
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('quiz_attempts')
          .where('isCompleted', isEqualTo: true)
          .orderBy('startTime', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => QuizAttempt.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== STATISTICS ====================

  Future<Map<String, dynamic>> getUserStatistics() async {
    if (currentUserId == null) {
      return {'totalQuizzes': 0, 'completedQuizzes': 0, 'averageScore': 0.0, 'totalAttempts': 0};
    }
    try {
      final attempts = await getAllUserAttempts();
      if (attempts.isEmpty) return {'totalQuizzes': 0, 'completedQuizzes': 0, 'averageScore': 0.0, 'totalAttempts': 0};

      final uniqueQuizzes = attempts.map((a) => a.quizId).toSet();
      final totalScore = attempts.fold<double>(0, (sum, attempt) => sum + attempt.percentage);

      return {
        'totalQuizzes': uniqueQuizzes.length,
        'completedQuizzes': uniqueQuizzes.length,
        'averageScore': totalScore / attempts.length,
        'totalAttempts': attempts.length,
      };
    } catch (e) {
      return {'totalQuizzes': 0, 'completedQuizzes': 0, 'averageScore': 0.0, 'totalAttempts': 0};
    }
  }

  // ==================== ADMIN OPERATIONS ====================

  Future<String?> uploadQuiz({
    required String categoryId,
    required String title,
    required String description,
    required int durationMinutes,
    required String difficulty,
    required List<String> tags,
    required List<Question> questions,
  }) async {
    try {
      final quizRef = _firestore
          .collection('exams')
          .doc(categoryId)
          .collection('quizzes')
          .doc();

      final quiz = Quiz(
        id: quizRef.id,
        title: title,
        description: description,
        categoryId: categoryId,
        totalQuestions: questions.length,
        durationMinutes: durationMinutes,
        maxMarks: questions.fold(0, (sum, q) => sum + q.marks),
        difficulty: difficulty,
        tags: tags,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await quizRef.set(quiz.toJson());

      for (var i = 0; i < questions.length; i++) {
        final question = questions[i];
        await quizRef.collection('questions').add({
          ...question.toJson(),
          'orderIndex': i,
        });
      }
      return quizRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteQuiz(String categoryId, String quizId) async {
    try {
      final questionsSnapshot = await _firestore
          .collection('exams')
          .doc(categoryId)
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get();

      for (var doc in questionsSnapshot.docs) {
        await doc.reference.delete();
      }
      await _firestore
          .collection('exams')
          .doc(categoryId)
          .collection('quizzes')
          .doc(quizId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleQuizStatus(String categoryId, String quizId, bool isActive) async {
    try {
      await _firestore
          .collection('exams')
          .doc(categoryId)
          .collection('quizzes')
          .doc(quizId)
          .update({'isActive': isActive});
      return true;
    } catch (e) {
      return false;
    }
  }
}
