import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_course/src/features/course/data/models/quiz_models.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/widgets/quiz_service.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/widgets/question_navigator.dart';
import 'quiz_result_page.dart';

// ─── DESIGN TOKENS (Premium Green Theme) ────────────────────────────────────

class _Clr {
  static const primary    = Color(0xFF1A56DB); // Brand Blue
  static const dark       = Color(0xFF1E40AF); // Deep Blue
  static const mid        = Color(0xFF2563EB); // Mid Blue
  static const medium     = Color(0xFF1A56DB); // Medium Blue
  static const light      = Color(0xFF60A5FA); // Soft Light Blue
  static const lighter    = Color(0xFF93C5FD); // Lighter Blue

  static const scaffoldBg = Color(0xFFF8F9FA); // Clean off-white
  static const surfaceEgg = Color(0xFFE6F3FF); // Blue tint surface
  static const border     = Color(0xFFD1D5DB); // Neutral border

  static const gold       = Color(0xFF3B82F6); // Standard Blue
  static const goldDark   = Color(0xFF1D4ED8); // Darker Blue
  static const red        = Color(0xFFEF4444);
  static const orange     = Color(0xFFF59E0B);

  static const ink        = Color(0xFF1A1A1A);
  static const inkMid     = Color(0xFF374151);
  static const inkLight   = Color(0xFF6B7280);
}

// ─────────────────────────────────────────────────────────────────────────────
//  QUIZ ATTEMPT PAGE
// ─────────────────────────────────────────────────────────────────────────────

class QuizAttemptPage extends StatefulWidget {
  final Quiz quiz;

  const QuizAttemptPage({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizAttemptPage> createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> with WidgetsBindingObserver {
  final QuizService _quizService = QuizService();

  List<QuestionState> questionStates = [];
  int currentQuestionIndex = 0;
  Timer? _timer;
  int remainingSeconds = 0;
  bool showQuestionPalette = false;
  bool isLoading = true;
  String? attemptId;

  int warningCount = 0;
  List<Map<String, dynamic>> violations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    remainingSeconds = widget.quiz.durationMinutes * 60;
    _loadQuestions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        warningCount++;
        violations.add({
          'type': 'APP_SWITCHED',
          'timestamp': DateTime.now().toIso8601String(),
          'warningNumber': warningCount,
        });
      });
      _showWarningDialog();
    }
  }

  void _showWarningDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Warning $warningCount: Please do not switch apps during the exam!'),
        backgroundColor: _Clr.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _loadQuestions() async {
    setState(() => isLoading = true);
    try {
      attemptId = await _quizService.startQuizAttempt(widget.quiz);
      final questions = await _quizService.getQuizQuestions(
        widget.quiz.categoryId,
        widget.quiz.id,
      );

      setState(() {
        questionStates = questions.map((q) => QuestionState(question: q)).toList();
        isLoading = false;
      });

      if (questionStates.isNotEmpty) {
        _startTimer();
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to load questions.');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _submitQuiz(autoSubmit: true);
        }
      });
    });
  }

  void _selectOption(int optionIndex) {
    setState(() {
      questionStates[currentQuestionIndex] = questionStates[currentQuestionIndex].copyWith(
        selectedOption: optionIndex,
        isAnswered: true,
      );
    });
  }

  void _toggleMarkForReview() {
    setState(() {
      questionStates[currentQuestionIndex] = questionStates[currentQuestionIndex].copyWith(
        isMarkedForReview: !questionStates[currentQuestionIndex].isMarkedForReview,
      );
    });
  }

  void _clearResponse() {
    setState(() {
      questionStates[currentQuestionIndex] = questionStates[currentQuestionIndex].copyWith(
        selectedOption: null,
        isAnswered: false,
      );
    });
  }

  void _navigateToQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
      showQuestionPalette = false;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questionStates.length - 1) {
      setState(() => currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() => currentQuestionIndex--);
    }
  }

  void _submitQuiz({bool autoSubmit = false}) async {
    _timer?.cancel();
    if (!autoSubmit) {
      final shouldSubmit = await _showSubmitDialog();
      if (shouldSubmit != true) {
        _startTimer();
        return;
      }
    }
    _navigateToResult();
  }

  Future<bool?> _showSubmitDialog() {
    final answeredCount = questionStates.where((q) => q.isAnswered).length;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Submit Quiz?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('You have answered $answeredCount out of ${questionStates.length} questions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: _Clr.primary), child: const Text('Submit Now')),
        ],
      ),
    );
  }

  void _navigateToResult() async {
    int correctAnswers = 0;
    int obtainedMarks = 0;
    int totalMarks = 0;
    Map<String, int?> answers = {};

    for (final state in questionStates) {
      answers[state.question.id] = state.selectedOption;
      totalMarks += state.question.marks;
      if (state.isAnswered && state.selectedOption == state.question.correctOptionIndex) {
        correctAnswers++;
        obtainedMarks += state.question.marks;
      }
    }

    if (totalMarks == 0) totalMarks = widget.quiz.maxMarks;

    final attempt = QuizAttempt(
      id: attemptId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      userId: _quizService.currentUserId ?? 'guest',
      userName: "Subhabrata",
      startTime: DateTime.now().subtract(Duration(seconds: widget.quiz.durationMinutes * 60 - remainingSeconds)),
      endTime: DateTime.now(),
      totalQuestions: questionStates.length,
      answeredQuestions: questionStates.where((q) => q.isAnswered).length,
      correctAnswers: correctAnswers,
      wrongAnswers: questionStates.where((q) => q.isAnswered && q.selectedOption != q.question.correctOptionIndex).length,
      skippedQuestions: questionStates.where((q) => !q.isAnswered).length,
      totalMarks: totalMarks,
      obtainedMarks: obtainedMarks,
      answers: answers,
      isCompleted: true,
      warningCount: warningCount,
    );

    if (attemptId != null) {
      await _quizService.submitQuizAttempt(attempt);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => QuizResultPage(quiz: widget.quiz, attempt: attempt, questionStates: questionStates)),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: _Clr.red));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return WillPopScope(
      onWillPop: () async {
        final exit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
            ],
          ),
        );
        return exit ?? false;
      },
      child: Scaffold(
        backgroundColor: _Clr.scaffoldBg,
        body: Column(
          children: [
            _buildCustomHeader(),
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questionStates.length,
              backgroundColor: _Clr.dark.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(_Clr.primary),
              minHeight: 4,
            ),
            Expanded(
              child: showQuestionPalette
                  ? QuestionNavigator(
                questionStates: questionStates,
                currentQuestionIndex: currentQuestionIndex,
                onQuestionTap: _navigateToQuestion,
              )
                  : _buildQuestionContent(),
            ),
            if (!showQuestionPalette) _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    final isLowTime = remainingSeconds < 60;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(color: _Clr.dark),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.quiz.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                Text('${questionStates.length} Questions', style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: isLowTime ? _Clr.red : Colors.white12, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(_formatTime(remainingSeconds), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            onPressed: () => setState(() => showQuestionPalette = !showQuestionPalette),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final currentQuestion = questionStates[currentQuestionIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Question ${currentQuestionIndex + 1}/${questionStates.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: _Clr.inkLight) // Explicit color
              ),
              Text(
                  '+ ${currentQuestion.question.marks} marks',
                  style: const TextStyle(color: _Clr.goldDark, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _Clr.border)),
            child: Text(
              currentQuestion.question.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _Clr.ink), // 🟢 ADDED EXPLICIT TEXT COLOR HERE
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            currentQuestion.question.options.length,
                (index) => _buildOptionCard(index, currentQuestion.question.options[index], currentQuestion.selectedOption == index),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, String text, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectOption(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _Clr.surfaceEgg : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? _Clr.primary : _Clr.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
                radius: 14,
                backgroundColor: isSelected ? _Clr.primary : _Clr.scaffoldBg,
                child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: isSelected ? Colors.white : _Clr.inkMid, // 🟢 ADDED EXPLICIT LETTER COLOR HERE
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    )
                )
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    text,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? _Clr.dark : _Clr.ink, // 🟢 ADDED EXPLICIT TEXT COLOR HERE
                    )
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _Clr.border))),
      child: Row(
        children: [
          if (currentQuestionIndex > 0) IconButton(onPressed: _previousQuestion, icon: const Icon(Icons.arrow_back_rounded)),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: () => currentQuestionIndex < questionStates.length - 1 ? _nextQuestion() : _submitQuiz(),
              style: FilledButton.styleFrom(backgroundColor: _Clr.primary, minimumSize: const Size(0, 56)),
              child: Text(currentQuestionIndex < questionStates.length - 1 ? 'Save & Next' : 'Submit Quiz'),
            ),
          ),
        ],
      ),
    );
  }
}
