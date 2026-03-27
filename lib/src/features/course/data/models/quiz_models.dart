// lib/features/quiz/models/quiz_models.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int quizCount;
  final Color color;

  ExamCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.quizCount,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quizCount': quizCount,
    };
  }

  factory ExamCategory.fromJson(Map<String, dynamic> json, IconData icon, Color color) {
    return ExamCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: icon,
      quizCount: json['quizCount'] ?? 0,
      color: color,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final int totalQuestions;
  final int durationMinutes;
  final int maxMarks;
  final String difficulty;
  final List<String> tags;
  final DateTime? lastAttempted;
  final int? bestScore;
  final bool isCompleted;
  final bool isActive;
  final DateTime? createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.maxMarks,
    required this.difficulty,
    required this.tags,
    this.lastAttempted,
    this.bestScore,
    this.isCompleted = false,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'totalQuestions': totalQuestions,
      'durationMinutes': durationMinutes,
      'maxMarks': maxMarks,
      'difficulty': difficulty,
      'tags': tags,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory Quiz.fromFirestore(DocumentSnapshot doc, {String? categoryId}) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Get categoryId from: 1) parameter, 2) document data, 3) extract from path
    String resolvedCategoryId = categoryId ?? data['categoryId'] ?? '';
    
    // If still empty, try to extract from document reference path
    // Path format: exams/{categoryId}/quizzes/{quizId}
    if (resolvedCategoryId.isEmpty) {
      final pathSegments = doc.reference.path.split('/');
      // Find 'exams' and get the next segment
      for (int i = 0; i < pathSegments.length - 1; i++) {
        if (pathSegments[i] == 'exams') {
          resolvedCategoryId = pathSegments[i + 1];
          break;
        }
      }
    }
    
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryId: resolvedCategoryId,
      totalQuestions: data['totalQuestions'] ?? 0,
      // Handle both 'durationMinutes' and 'timeLimit' field names
      durationMinutes: data['durationMinutes'] ?? data['timeLimit'] ?? 0,
      maxMarks: data['maxMarks'] ?? 0,
      difficulty: data['difficulty'] ?? 'Medium',
      tags: List<String>.from(data['tags'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isCompleted: false,
    );
  }

  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    int? totalQuestions,
    int? durationMinutes,
    int? maxMarks,
    String? difficulty,
    List<String>? tags,
    DateTime? lastAttempted,
    int? bestScore,
    bool? isCompleted,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      maxMarks: maxMarks ?? this.maxMarks,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      lastAttempted: lastAttempted ?? this.lastAttempted,
      bestScore: bestScore ?? this.bestScore,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Question {
  final String id;
  final String quizId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final int marks;
  final String? imageUrl;
  final int orderIndex;

  Question({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    required this.marks,
    this.imageUrl,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'marks': marks,
      'imageUrl': imageUrl,
      'orderIndex': orderIndex,
    };
  }

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      quizId: data['quizId'] ?? '',
      // Handle both 'questionText' and 'question' field names
      questionText: data['questionText'] ?? data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      // Handle both 'correctOptionIndex' and 'correctIndex' field names
      correctOptionIndex: data['correctOptionIndex'] ?? data['correctIndex'] ?? 0,
      explanation: data['explanation'],
      marks: data['marks'] ?? 1,
      imageUrl: data['imageUrl'],
      orderIndex: data['orderIndex'] ?? 0,
    );
  }
}
class QuizAttempt {
  final String id;
  final String quizId;
  final String quizTitle;     // 🟢 Added to fix "General Quiz"
  final String userId;
  final String userName;      // 🟢 Added to fix "User ID" visibility
  final DateTime startTime;
  final DateTime? endTime;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final int totalMarks;
  final int obtainedMarks;
  final Map<String, int?> answers;
  final bool isCompleted;
  final int warningCount;     // 🟢 Added to track "APP_SWITCHED" violations

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.userId,
    required this.userName,
    required this.startTime,
    this.endTime,
    required this.totalQuestions,
    this.answeredQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.skippedQuestions = 0,
    required this.totalMarks,
    this.obtainedMarks = 0,
    required this.answers,
    this.isCompleted = false,
    this.warningCount = 0,
  });

  double get percentage =>
      totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;

  double get accuracy =>
      answeredQuestions > 0 ? (correctAnswers / answeredQuestions) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'userId': userId,
      'userName': userName,
      // Using server-side compatible formats
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'skippedQuestions': skippedQuestions,
      'totalMarks': totalMarks,
      'obtainedMarks': obtainedMarks,
      'answers': answers,
      'isCompleted': isCompleted,
      'percentage': percentage,
      'accuracy': accuracy,
      'warningCount': warningCount,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // 🛠️ SMART DATE PARSER: Handles both Timestamp and String formats
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return QuizAttempt(
      id: doc.id,
      quizId: data['quizId'] ?? '',
      quizTitle: data['quizTitle'] ?? 'General Quiz',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Student',
      startTime: parseDate(data['startTime']),
      endTime: data['endTime'] != null ? parseDate(data['endTime']) : null,
      totalQuestions: data['totalQuestions'] ?? 0,
      answeredQuestions: data['answeredQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      wrongAnswers: data['wrongAnswers'] ?? 0,
      skippedQuestions: data['skippedQuestions'] ?? 0,
      totalMarks: data['totalMarks'] ?? 0,
      obtainedMarks: data['obtainedMarks'] ?? 0,
      answers: Map<String, int?>.from(data['answers'] ?? {}),
      isCompleted: data['isCompleted'] ?? false,
      warningCount: (data['warningCount'] ?? 0).toInt(),
    );
  }
}

class QuestionState {
  final Question question;
  final int? selectedOption;
  final bool isMarkedForReview;
  final bool isAnswered;

  QuestionState({
    required this.question,
    this.selectedOption,
    this.isMarkedForReview = false,
    this.isAnswered = false,
  });

  QuestionState copyWith({
    Question? question,
    int? selectedOption,
    bool? isMarkedForReview,
    bool? isAnswered,
  }) {
    return QuestionState(
      question: question ?? this.question,
      selectedOption: selectedOption ?? this.selectedOption,
      isMarkedForReview: isMarkedForReview ?? this.isMarkedForReview,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }
}
