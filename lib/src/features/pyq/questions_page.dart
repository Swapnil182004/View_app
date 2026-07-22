import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _firestoreService.getQuestions(examId, yearId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: cs.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading questions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
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
                          colors: [cs.primary.withOpacity(0.1), cs.secondary.withOpacity(0.1)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.quiz_outlined, size: 64, color: cs.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Questions Available',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new questions',
                      style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
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
              final data = question.data() as Map<String, dynamic>?;
              
              final questionTitle = data?['question_title'] as String? ?? 'Untitled';
              
              String marksStr = '';
              if (data != null && data.containsKey('marks')) {
                final marks = data['marks'];
                if (marks != null) {
                  marksStr = marks.toString();
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                questionTitle,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if ((data?['pdf_url'] as String? ?? '').isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  final pdfUrl = data?['pdf_url'] as String? ?? '';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PdfViewer(url: pdfUrl),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFE67E22)),
                                tooltip: 'View PDF',
                              ),
                          ],
                        ),
                        if (marksStr.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$marksStr marks',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}