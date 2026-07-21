import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:online_course/src/features/course/data/models/quiz_models.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/widgets/quiz_service.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/widgets/exam_category.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/widgets/quiz_list_page.dart';

// ─── DESIGN TOKENS (Matching the Dashboard) ─────────────────────────────────

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

  static const gold       = Colors.white; // White for dark backgrounds
  static const goldDark   = Color(0xFF1D4ED8); // Darker blue for light backgrounds

  static const ink        = Color(0xFF1A1A1A);
  static const inkMid     = Color(0xFF374151);
  static const inkLight   = Color(0xFF6B7280);
}

// ─── GRADIENT HELPERS ────────────────────────────────────────────────────────

const _kThemeGrad = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_Clr.dark, _Clr.medium],
);

const _kThemeGradLight = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_Clr.mid, _Clr.light],
);

List<BoxShadow> _themeShadow({double blur = 20, double opacity = 0.18}) => [
  BoxShadow(
    color: _Clr.primary.withOpacity(opacity),
    blurRadius: blur,
    spreadRadius: 0,
    offset: const Offset(0, 6),
  ),
];

List<BoxShadow> _cardShadow() => [
  BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 12,
    offset: const Offset(0, 2),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  QUIZ MAIN PAGE
// ─────────────────────────────────────────────────────────────────────────────

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({Key? key}) : super(key: key);

  @override
  State<QuizMainPage> createState() => _QuizMainPageState();
}

class _QuizMainPageState extends State<QuizMainPage> {
  final QuizService _quizService = QuizService();

  String _searchQuery = '';
  Map<String, dynamic>? _userStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserStatistics();
  }

  Future<void> _loadUserStatistics() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await _quizService.getUserStatistics();
      setState(() {
        _userStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Clr.scaffoldBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _Clr.dark,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz History - Coming Soon!'), backgroundColor: _Clr.primary),
                  );
                },
                tooltip: 'Quiz History',
              ),
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded, color: _Clr.gold),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leaderboard - Coming Soon!'), backgroundColor: _Clr.primary),
                  );
                },
                tooltip: 'Leaderboard',
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(gradient: _kThemeGrad),
                child: Stack(
                  children: [
                    // Decorative Background Circles
                    Positioned(right: -30, top: -30,
                        child: Container(width: 180, height: 180, decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle))),
                    Positioned(right: 60, bottom: -20,
                        child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle))),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withOpacity(0.22)),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.quiz_rounded, size: 12, color: _Clr.gold),
                                SizedBox(width: 6),
                                Text('ASSESSMENT CENTER', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                              ]),
                            ),
                            const SizedBox(height: 12),
                            const Text('Mock Tests & Quizzes',
                                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // ─── SEARCH BAR ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search exams...',
                  hintStyle: const TextStyle(color: _Clr.inkLight, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: _Clr.primary, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: _Clr.inkLight, size: 18),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                      : null,
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _Clr.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _Clr.border, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _Clr.primary, width: 2)),
                ),
              ),
            ),

            // ─── STATS OVERVIEW ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _isLoadingStats
                  ? const Center(child: CircularProgressIndicator(color: _Clr.primary))
                  : Row(
                children: [
                  Expanded(child: _StatCard(icon: Icons.quiz_rounded, label: 'Total Quizzes', value: '${_userStats?['totalQuizzes'] ?? 0}', color: _Clr.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.check_circle_rounded, label: 'Completed', value: '${_userStats?['completedQuizzes'] ?? 0}', color: _Clr.light)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.trending_up_rounded, label: 'Avg Score', value: '${(_userStats?['averageScore'] ?? 0).toStringAsFixed(0)}%', color: _Clr.goldDark)),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Available Exams', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _Clr.ink)),
              ),
            ),

            // ─── FIREBASE EXAMS GRID ───
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('exams').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _Clr.primary));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading exams', style: TextStyle(color: Colors.red)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState('No exams available yet', Icons.school_outlined);
                  }

                  // 1. Map Firestore documents
                  var docs = snapshot.data!.docs;

                  // 2. Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['title'] ?? data['name'] ?? '').toString().toLowerCase();
                      final desc = (data['description'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery.toLowerCase()) || desc.contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return _buildEmptyState('No exams match your search', Icons.search_off_rounded);
                  }

                  // 3. Render Grid
                  return RefreshIndicator(
                    onRefresh: _loadUserStatistics,
                    color: _Clr.primary,
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.75, // ✅ FIXED: Increased height to absolutely guarantee no overflow
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        // Dynamically build the ExamCategory object to pass to the next page
                        final category = ExamCategory(
                          id: docs[index].id,
                          name: data['title'] ?? data['name'] ?? 'Unknown Exam',
                          description: data['description'] ?? 'Exam materials',
                          icon: Icons.school_rounded, // Fallback icon
                          quizCount: data['quizCount'] ?? 0,
                          color: _Clr.primary,
                        );

                        return _PremiumExamCard(
                          category: category,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => QuizListPage(category: category)
                            )).then((_) => _loadUserStatistics()); // Refresh stats on return
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: _Clr.surfaceEgg, shape: BoxShape.circle),
            child: Icon(icon, size: 48, color: _Clr.primary),
          ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _Clr.inkLight)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PREMIUM EXAM CARD WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumExamCard extends StatelessWidget {
  final ExamCategory category;
  final VoidCallback onTap;

  const _PremiumExamCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _Clr.border, width: 1.5),
          boxShadow: _cardShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top gradient strip
            Container(
              height: 6,
              decoration: const BoxDecoration(
                gradient: _kThemeGradLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14), // ✅ FIXED: Reduced padding slightly to ensure everything fits beautifully
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Circle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: _Clr.surfaceEgg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_rounded, color: _Clr.primary, size: 24),
                    ),
                    const SizedBox(height: 12),
                    // Texts
                    Expanded( // ✅ FIXED: Wrapped texts in Expanded so it gracefully handles multiline without breaking the flex bounds
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _Clr.ink),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.description,
                            style: const TextStyle(fontSize: 11, color: _Clr.inkLight, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stats pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _Clr.surfaceEgg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.quiz_rounded, size: 12, color: _Clr.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${category.quizCount} Quizzes',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _Clr.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STAT CARD WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Clr.border),
        boxShadow: _cardShadow(),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: const TextStyle(fontSize: 10, color: _Clr.inkLight, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
