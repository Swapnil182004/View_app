// lib/screens/news_list_screen.dart
import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/news_model.dart';
import 'package:online_course/core/services/news_service.dart';
import 'package:online_course/src/features/course/pesentation/pages/news/widget/news_card.dart';
import 'news_detail_screen.dart';

// ─── DESIGN TOKENS (Premium Green Theme) ────────────────────────────────────
class _Clr {
  static const primary    = Color(0xFF1A56DB);
  static const dark       = Color(0xFF1E40AF);
  static const scaffoldBg = Color(0xFFF8F9FA);
  static const surfaceEgg = Color(0xFFE6F3FF);
  static const border     = Color(0xFFD1D5DB);
  static const gold       = Colors.white;
  static const ink        = Color(0xFF1A1A1A);
  static const inkMid     = Color(0xFF374151);
  static const inkLight   = Color(0xFF6B7280);
}

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  String? _selectedCategory;

  final List<String> _categories = ['All', 'Academic', 'Event', 'Notice', 'General'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Clr.scaffoldBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _Clr.dark,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E40AF), Color(0xFF60A5FA)], // Deep Blue to Light Blue
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle),
                      ),
                    ),
                    Positioned(
                      right: 60, bottom: -20,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
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
                                Icon(Icons.newspaper_rounded, size: 12, color: Colors.white), // White instead of orange
                                SizedBox(width: 6),
                                Text('NEWS CENTER', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                              ]),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'News & Updates',
                              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
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
            // ─── CATEGORY FILTER CHIPS ───
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: _Clr.border, width: 1.5)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category ||
                        (_selectedCategory == null && category == 'All');
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category == 'All' ? null : category;
                          });
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
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ─── NEWS LIST ───
            Expanded(
              child: StreamBuilder<List<NewsModel>>(
                stream: _newsService.getNewsStream(),
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _Clr.primary));
                  }

                  // Error
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(color: Color(0xFFFFEEEE), shape: BoxShape.circle),
                            child: const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFEF4444)),
                          ),
                          const SizedBox(height: 16),
                          const Text('Error loading news', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _Clr.inkMid)),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                            style: FilledButton.styleFrom(backgroundColor: _Clr.primary),
                          ),
                        ],
                      ),
                    );
                  }

                  // Empty
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(color: _Clr.surfaceEgg, shape: BoxShape.circle),
                            child: const Icon(Icons.newspaper_rounded, size: 48, color: _Clr.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text('No news available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _Clr.ink)),
                          const SizedBox(height: 6),
                          const Text('Check back later for updates', style: TextStyle(fontSize: 13, color: _Clr.inkLight)),
                        ],
                      ),
                    );
                  }

                  // Filter
                  List<NewsModel> newsList = snapshot.data!;
                  if (_selectedCategory != null) {
                    newsList = newsList.where((n) => n.category == _selectedCategory).toList();
                  }

                  if (newsList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(color: _Clr.surfaceEgg, shape: BoxShape.circle),
                            child: const Icon(Icons.filter_list_off_rounded, size: 48, color: _Clr.primary),
                          ),
                          const SizedBox(height: 16),
                          Text('No $_selectedCategory news', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _Clr.inkMid)),
                        ],
                      ),
                    );
                  }

                  // Success
                  return RefreshIndicator(
                    color: _Clr.primary,
                    onRefresh: () async {
                      setState(() {});
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        return NewsCard(
                          news: news,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
                            );
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
}
