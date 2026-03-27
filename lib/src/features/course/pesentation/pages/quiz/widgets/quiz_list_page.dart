import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_course/src/features/course/data/models/quiz_models.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/widgets/quiz_service.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/widgets/quiz_card.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/widgets/anti_cheat_wrapper.dart'; // ✅ Added Anti-Cheat Import
import 'quiz_attempt_page.dart';

// ─── DESIGN TOKENS ──────────────────────────────────────────────────────────
class _Clr {
  static const primary    = Color(0xFF1A56DB); // Brand Blue
  static const dark       = Color(0xFF1E40AF); // Deep Blue
  static const mid        = Color(0xFF2563EB); // Mid Blue
  static const surfaceEgg = Color(0xFFE6F3FF); // Blue tint surface
  static const border     = Color(0xFFD1D5DB); // Neutral border
  static const scaffoldBg = Color(0xFFF8F9FA); // Clean off-white
  static const ink        = Color(0xFF1A1A1A);
  static const inkMid     = Color(0xFF374151);
  static const inkLight   = Color(0xFF6B7280);
}

// ─────────────────────────────────────────────────────────────────────────────
//  QUIZ LIST PAGE
// ─────────────────────────────────────────────────────────────────────────────

class QuizListPage extends StatefulWidget {
  final ExamCategory category;

  const QuizListPage({Key? key, required this.category}) : super(key: key);

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final QuizService _quizService = QuizService();
  String _selectedDifficulty = 'All';
  String _searchQuery = '';

  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ Updated to fetch directly from the Admin's subcollection hierarchy
      final querySnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.category.id)
          .collection('quizzes')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Map dynamic documents to Quiz model
        _quizzes = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Quiz(
            id: doc.id,
            categoryId: widget.category.id,
            title: data['title'] ?? 'Untitled Quiz',
            description: data['description'] ?? 'No description provided.',
            difficulty: data['difficulty'] ?? 'Medium',
            totalQuestions: data['totalQuestions'] ?? 0,
            durationMinutes: data['durationMinutes'] ?? 30,
            maxMarks: data['maxMarks'] ?? 100,
            tags: List<String>.from(data['tags'] ?? []),
          );
        }).toList();
      } else {
        // Fallback to QuizService if no subcollection data exists yet
        _quizzes = await _quizService.getQuizzesByCategory(widget.category.id);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading quizzes: $e');
      setState(() {
        _errorMessage = 'Failed to load quizzes. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  List<Quiz> get filteredQuizzes {
    return _quizzes.where((quiz) {
      final matchesDifficulty = _selectedDifficulty == 'All' ||
          quiz.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase();
      final matchesSearch = quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          quiz.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesDifficulty && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Clr.scaffoldBg,
      appBar: AppBar(
        backgroundColor: _Clr.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.category.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadQuizzes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── SEARCH & FILTER SECTION ───
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: _Clr.border, width: 1.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search quizzes...',
                    hintStyle: const TextStyle(color: _Clr.inkLight, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: _Clr.primary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: _Clr.inkLight, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                        : null,
                    filled: true,
                    fillColor: _Clr.scaffoldBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.transparent)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _Clr.primary, width: 1.5)),
                  ),
                ),

                const SizedBox(height: 16),

                // Difficulty Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 10),
                      _buildFilterChip('Easy'),
                      const SizedBox(width: 10),
                      _buildFilterChip('Medium'),
                      const SizedBox(width: 10),
                      _buildFilterChip('Hard'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── QUIZ LIST ───
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _Clr.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFFFEEEE), shape: BoxShape.circle),
              child: const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontSize: 14, color: _Clr.inkMid, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadQuizzes,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: _Clr.primary),
            ),
          ],
        ),
      );
    }

    final filtered = filteredQuizzes;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: _Clr.surfaceEgg, shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, size: 48, color: _Clr.primary),
            ),
            const SizedBox(height: 16),
            const Text('No quizzes found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _Clr.ink)),
            const SizedBox(height: 6),
            const Text('Try adjusting your search or filters.', style: TextStyle(fontSize: 13, color: _Clr.inkLight)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      color: _Clr.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return QuizCard(
            quiz: filtered[index],
            onTap: () {
              // ✅ WRAPPED IN ANTI-CHEAT SYSTEM BEFORE NAVIGATION
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AntiCheatQuizWrapper(
                    quizId: filtered[index].id,
                    quizTitle: filtered[index].title,
                    child: QuizAttemptPage(quiz: filtered[index]),
                  ),
                ),
              ).then((_) {
                _loadQuizzes();
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedDifficulty == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedDifficulty = label);
      },
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: _Clr.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : _Clr.inkMid,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? _Clr.primary : _Clr.border,
          width: 1.5,
        ),
      ),
    );
  }
}
