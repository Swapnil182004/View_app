// lib/features/quiz/pages/quiz_review_page.dart
import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/quiz_models.dart';

class QuizReviewPage extends StatefulWidget {
  final Quiz quiz;
  final QuizAttempt attempt;
  final List<QuestionState> questionStates;

  const QuizReviewPage({
    Key? key,
    required this.quiz,
    required this.attempt,
    required this.questionStates,
  }) : super(key: key);

  @override
  State<QuizReviewPage> createState() => _QuizReviewPageState();
}

class _QuizReviewPageState extends State<QuizReviewPage> {
  int currentQuestionIndex = 0;
  String filterType = 'All'; // All, Correct, Wrong, Skipped

  List<QuestionState> get filteredQuestions {
    switch (filterType) {
      case 'Correct':
        return widget.questionStates.where((q) {
          return q.isAnswered &&
              q.selectedOption == q.question.correctOptionIndex;
        }).toList();
      case 'Wrong':
        return widget.questionStates.where((q) {
          return q.isAnswered &&
              q.selectedOption != q.question.correctOptionIndex;
        }).toList();
      case 'Skipped':
        return widget.questionStates.where((q) => !q.isAnswered).toList();
      default:
        return widget.questionStates;
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = filteredQuestions;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Answers')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.filter_alt_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No questions in this filter',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = currentQuestion.isAnswered &&
        currentQuestion.selectedOption ==
            currentQuestion.question.correctOptionIndex;
    final isWrong = currentQuestion.isAnswered && !isCorrect;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips - WRAPPED IN FLEXIBLE
            Flexible(
              flex: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', widget.questionStates.length),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Correct',
                        widget.questionStates
                            .where((q) =>
                                q.isAnswered &&
                                q.selectedOption == q.question.correctOptionIndex)
                            .length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Wrong',
                        widget.questionStates
                            .where((q) =>
                                q.isAnswered &&
                                q.selectedOption != q.question.correctOptionIndex)
                            .length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Skipped',
                        widget.questionStates.where((q) => !q.isAnswered).length,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Question Progress
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCorrect
                    ? const Color(0xFF1A56DB)
                    : isWrong
                        ? const Color(0xFFE67E22)
                        : Colors.grey,
              ),
              minHeight: 4,
            ),

            // Question Header - WRAPPED IN FLEXIBLE
            Flexible(
              flex: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: isCorrect
                    ? const Color(0xFFE8ECF9)
                    : isWrong
                        ? const Color(0xFFFFE8DD)
                        : const Color(0xFFFFF9E6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Question ${currentQuestionIndex + 1} of ${questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFF1A56DB)
                            : isWrong
                                ? const Color(0xFFE67E22)
                                : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle
                                : isWrong
                                    ? Icons.cancel
                                    : Icons.remove_circle_outline,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCorrect
                                ? 'Correct'
                                : isWrong
                                    ? 'Wrong'
                                    : 'Skipped',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Question Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Text
                    Text(
                      currentQuestion.question.questionText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Options
                    ...List.generate(
                      currentQuestion.question.options.length,
                      (index) => _buildReviewOptionCard(
                        index,
                        currentQuestion.question.options[index],
                        currentQuestion.selectedOption == index,
                        currentQuestion.question.correctOptionIndex == index,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Explanation (if available)
                    if (currentQuestion.question.explanation != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1D4ED8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: const Color(0xFF1D4ED8),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Explanation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion.question.explanation!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Extra padding at bottom to ensure content isn't hidden
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Navigation Footer - MADE SAFER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            currentQuestionIndex--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (currentQuestionIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: currentQuestionIndex < questions.length - 1
                        ? ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            },
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Next'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Finish Review'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A56DB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = filterType == label;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          filterType = label;
          currentQuestionIndex = 0;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFE8ECF9),
      checkmarkColor: const Color(0xFF1A56DB),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1A56DB) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1A56DB) : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildReviewOptionCard(
    int index,
    String optionText,
    bool isSelected,
    bool isCorrect,
  ) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCorrect) {
      backgroundColor = const Color(0xFFE8ECF9);
      borderColor = const Color(0xFF1A56DB);
      textColor = const Color(0xFF1A56DB);
    } else if (isSelected && !isCorrect) {
      backgroundColor = const Color(0xFFFFE8DD);
      borderColor = const Color(0xFFE67E22);
      textColor = const Color(0xFFE67E22);
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade200;
      textColor = const Color(0xFF1A1A1A);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: (isSelected || isCorrect) ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: (isSelected || isCorrect) ? 2 : 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Option Letter
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF1A56DB)
                    : isSelected && !isCorrect
                        ? const Color(0xFFE67E22)
                        : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (isCorrect || (isSelected && !isCorrect))
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Option Text
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight:
                      (isSelected || isCorrect) ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            // Status Icon
            if (isCorrect)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1A56DB),
                size: 24,
              )
            else if (isSelected && !isCorrect)
              const Icon(
                Icons.cancel,
                color: Color(0xFFE67E22),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
