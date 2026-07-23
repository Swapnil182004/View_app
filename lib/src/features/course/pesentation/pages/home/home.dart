import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_course/core/utils/dummy_data.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/core/services/news_service.dart';
import 'package:online_course/src/features/course/data/models/news_model.dart';
import 'package:online_course/src/features/course/pesentation/pages/home/widgets/home_appbar.dart';
import 'package:online_course/src/features/course/pesentation/pages/home/widgets/home_banner.dart';
import 'package:online_course/src/features/course/pesentation/pages/home/widgets/home_category.dart';
import 'package:online_course/src/features/course/pesentation/pages/home/widgets/home_feature_block.dart';
import 'package:online_course/src/features/course/pesentation/pages/home/widgets/home_recommend_block.dart';
import 'package:online_course/src/features/course/pesentation/pages/explore/explore.dart';
import 'package:online_course/src/features/course/pesentation/pages/news/news_detail_screen.dart';
import 'package:online_course/src/root_app.dart';
import 'package:url_launcher/url_launcher_string.dart';
// ✅ IMPORT YOUR NEW BANNER AND THE DASHBOARD LOADER
import 'package:online_course/src/features/course/pesentation/pages/home/widgets/syllabus_promo_banner.dart';
import 'package:online_course/src/features/onboarding/presentation/syllabus_setup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _user = FirebaseAuth.instance.currentUser;
  final _newsService = NewsService();
  String bannerUrl = '';
  String currentVersion = '1.0';

  @override
  void initState() {
    super.initState();
    checkForUpdates();
    fetchBanner();
  }

  // ✅ Category Navigation Handler
  void _handleCategoryTap(int tabIndex) {
    try {
      final rootAppState = context.findAncestorStateOfType<RootAppState>();
      if (rootAppState != null) {
        rootAppState.onPageChanged(tabIndex);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Navigation error: $e');
      }
    }
  }

  // ✅ Syllabus Banner Tap — Wired up to the DashboardLoader
  void _handleSyllabusBannerTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DashboardLoader()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: LiquidPullToRefresh(
        color: cs.primary,
        backgroundColor: cs.surface,
        showChildOpacityTransition: false,
        onRefresh: () async {
          await fetchBanner();
          if (mounted) {
            setState(() {});
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1️⃣ ✅ GRADIENT HEADER
            SliverAppBar(
              backgroundColor: Colors.transparent, // ✅ Brand Green AppBar
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              surfaceTintColor: Colors.transparent,
              pinned: true,
              snap: true,
              floating: true,
              toolbarHeight: 74,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: HomeAppBar(user: _user),
              ),
              elevation: 0,
              scrolledUnderElevation: 0.5,
            ),

            // 2️⃣ SEARCH BAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                child: _buildSearchBar(context),
              ),
            ),

            // 3️⃣ BANNER SLIDER
            SliverPadding(
              padding: const EdgeInsets.only(top: 10),
              sliver: SliverToBoxAdapter(
                child: RoundedBannerImage(imageUrl: bannerUrl),
              ),
            ),

            // 4️⃣ CATEGORIES
            SliverToBoxAdapter(
              child: HomeCategory(
                categories: categories,
                onCategoryTap: _handleCategoryTap,
              ),
            ),

            // ✅ 5️⃣ SYLLABUS DASHBOARD PROMO BANNER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 30),
                child: SyllabusPromoBanner(
                  onEnrollTap: _handleSyllabusBannerTap,
                ),
              ),
            ),

            // 6️⃣ FEATURED COURSES
            const SliverToBoxAdapter(child: HomeFeatureBlock()),
            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // 7️⃣ RECOMMENDED COURSES
            const SliverToBoxAdapter(child: HomeRecommendBlcok()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ✅ 8️⃣ RECENT NEWS — Using existing NewsService
            SliverToBoxAdapter(
              child: _buildRecentNewsSection(context),
            ),
            //bottom empty space
            const SliverToBoxAdapter(child: SizedBox(height: 200)),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────
  // ✅ RECENT NEWS SECTION — Reuses NewsService
  // ──────────────────────────────────────────────────
  Widget _buildRecentNewsSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recent News',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.primary, // Enthusiastic Green
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal news cards from existing NewsService
        SizedBox(
          height: 220,
          child: StreamBuilder<List<NewsModel>>(
            stream: _newsService.getNewsStream(),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary, // Green tint
                  ),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Could not load news',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              // Empty state
              final newsList = snapshot.data ?? [];
              if (newsList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.newspaper_rounded,
                        size: 40,
                        color: cs.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No news yet — stay tuned!',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Data state — horizontal list
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final news = newsList[index];
                  return _buildNewsCard(context, news: news);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────
  // ✅ INDIVIDUAL NEWS CARD — Text-only, professional
  // ──────────────────────────────────────────────────
  Widget _buildNewsCard(
    BuildContext context, {
    required NewsModel news,
  }) {
    final catInfo = news.categoryInfo;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsDetailScreen(news: news),
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ Colored accent bar on left
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: catInfo.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // ✅ Text content — no images
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catInfo.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        catInfo.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: catInfo.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Headline
                    Expanded(
                      child: Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Date
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          news.formattedDate,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ],
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

  // SEARCH BAR
  Widget _buildSearchBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        AppNavigator.to(context, const ExplorePage());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outline.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: cs.onSurfaceVariant, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search courses, notes, PYQs...',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune,
                color: cs.primary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchBanner() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app')
          .doc('homeScreen')
          .get();

      if (mounted && doc.exists) {
        setState(() {
          bannerUrl = doc.data()?['banner'] ?? '';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching banner: $e');
      }
    }
    await _setData();
  }

  Future<void> _setData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'pic': user.photoURL ?? '',
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user data: $e');
      }
    }
  }

  void checkForUpdates() {
    FirebaseFirestore.instance
        .collection('app')
        .doc('meta')
        .get()
        .then((value) {
      if (!value.exists) return;

      final data = value.data();
      if (data == null) return;

      if (data['version'] != '2.5') {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            final cs = Theme.of(context).colorScheme;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                data['title'] ?? 'Update Available',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                data['text'] ?? "Refer official website for more info.",
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onSurfaceVariant,
                  ),
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  onPressed: () {
                    launchUrlString(
                      data['link'] ?? 'http://viewinstitute.com/',
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.secondary,
                    foregroundColor: cs.onSecondary,
                  ),
                  child: Text(data['action'] ?? 'Download Update'),
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Error checking updates: $error');
      }
    });
  }
}
