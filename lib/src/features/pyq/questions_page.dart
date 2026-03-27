import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/document_viewer/presentation/pdf_viewer.dart';

import 'presentation/pages/chat/data/questions_service.dart';

class QuestionsPage extends StatelessWidget {
  final String examId;
  final String yearId;
  final FirestoreService _firestoreService = FirestoreService();

  QuestionsPage({super.key, required this.examId, required this.yearId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
        // ✅ AppBar uses theme automatically
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _firestoreService.getQuestions(examId, yearId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: cs.primary, // ✅ VIEW Purple
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: cs.error, // ✅ Theme error color
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cs.primary.withOpacity(0.1),
                            cs.secondary.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: cs.primary, // ✅ VIEW Purple
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Questions Available',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new questions',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final difficulty = question['difficulty'] ?? '';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildQuestionCard(context, question, difficulty),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    QueryDocumentSnapshot question,
    String difficulty,
  ) {
    final cs = Theme.of(context).colorScheme;
    
    // ✅ Determine difficulty color based on theme
    Color difficultyColor;
    if (difficulty.toLowerCase().contains('easy')) {
      difficultyColor = cs.tertiary; // ✅ VIEW Pink for easy
    } else if (difficulty.toLowerCase().contains('hard')) {
      difficultyColor = cs.error; // ✅ Red for hard
    } else {
      difficultyColor = cs.secondary; // ✅ VIEW Cyan for medium
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          AppNavigator.to(
            context,
            PdfViewer(url: question['pdf_url'] ?? ''),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ✅ Icon with gradient background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withOpacity(0.1),
                      cs.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.quiz,
                  color: cs.primary, // ✅ VIEW Purple
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // ✅ Question info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['question_title'] ?? 'Untitled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface, // ✅ Theme-driven
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.subject,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            question['subject'] ?? 'General',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant, // ✅ Theme-driven
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // ✅ Difficulty and count badge
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: difficultyColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      difficulty.isEmpty ? 'Medium' : difficulty,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: difficultyColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.question_answer,
                        size: 14,
                        color: cs.primary, // ✅ VIEW Purple
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${question['total_questions'] ?? 0}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.primary, // ✅ VIEW Purple
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
