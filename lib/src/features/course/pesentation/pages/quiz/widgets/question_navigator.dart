// lib/features/quiz/widgets/question_navigator.dart
import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/quiz_models.dart';

class QuestionNavigator extends StatelessWidget {
  final List<QuestionState> questionStates;
  final int currentQuestionIndex;
  final Function(int) onQuestionTap;

  const QuestionNavigator({
    Key? key,
    required this.questionStates,
    required this.currentQuestionIndex,
    required this.onQuestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final answeredCount = questionStates.where((q) => q.isAnswered).length;
    final markedCount = questionStates.where((q) => q.isMarkedForReview).length;
    final notVisitedCount = questionStates.length - answeredCount - markedCount;

    return Column(
      children: [
        // Legend
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFF9E6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Question Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(
                    color: const Color(0xFF1A56DB),
                    label: 'Answered',
                    count: answeredCount,
                  ),
                  _buildLegendItem(
                    color: const Color(0xFF2563EB),
                    label: 'Marked',
                    count: markedCount,
                  ),
                  _buildLegendItem(
                    color: Colors.grey.shade300,
                    label: 'Not Visited',
                    count: notVisitedCount,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Question Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: questionStates.length,
            itemBuilder: (context, index) {
              final state = questionStates[index];
              final isCurrent = index == currentQuestionIndex;

              Color backgroundColor;
              Color textColor;
              Color borderColor;

              if (state.isAnswered) {
                backgroundColor = const Color(0xFF1A56DB);
                textColor = Colors.white;
                borderColor = const Color(0xFF1A56DB);
              } else if (state.isMarkedForReview) {
                backgroundColor = const Color(0xFF2563EB);
                textColor = Colors.white;
                borderColor = const Color(0xFF2563EB);
              } else {
                backgroundColor = Colors.white;
                textColor = Colors.grey.shade700;
                borderColor = Colors.grey.shade300;
              }

              return InkWell(
                onTap: () => onQuestionTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                      color: isCurrent ? const Color(0xFF1A56DB) : borderColor,
                      width: isCurrent ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (state.isMarkedForReview)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Icons.bookmark,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
