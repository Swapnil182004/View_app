// lib/src/features/onboarding/presentation/onboarding_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_course/core/services/auth_service.dart';
import 'package:online_course/src/features/collection_form/collection_form.dart';
import 'package:online_course/src/root_app.dart';
import 'package:online_course/src/features/onboarding/presentation/syllabus_setup_screen.dart';

// ─── Page image list ──────────────────────────────────────────────────────────

const List<String> _pageImages = [
  'assets/images/onboarding 1.jpeg',
  'assets/images/onboarding 2.jpeg',
  'assets/images/onboarding 3.jpeg',
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _isInitialized = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _controller = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
      );

      setState(() => _isInitialized = true);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isInitialized) _animationController.dispose();
    super.dispose();
  }

  // ── Dot indicator ─────────────────────────────────────────────────────────

  AnimatedContainer _buildDot({required int index}) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: _currentPage == index
            ? cs.primary
            : cs.onSurfaceVariant.withOpacity(0.3),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final cs = Theme.of(context).colorScheme;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

            // ── LAYER 1 — Full-screen PageView of images ──────────────────
            PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: _controller,
              onPageChanged: (value) {
                if (mounted) setState(() => _currentPage = value);
              },
              itemCount: _pageImages.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 100), // Larger bottom padding to avoid buttons
                  child: Image.asset(
                    _pageImages[i],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Icon(
                          i == 0
                              ? Icons.school_outlined
                              : i == 1
                                  ? Icons.menu_book_outlined
                                  : Icons.rocket_launch_outlined,
                          size: 120,
                          color: cs.primary.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── LAYER 2 — White gradient fade at bottom ───────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height * 0.24,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.92),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // ── LAYER 3 — Dots + Buttons + Tagline ───────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Page indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pageImages.length,
                        (index) => _buildDot(index: index),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Last page → Google sign-in / other pages → Skip + Next
                    _currentPage + 1 == _pageImages.length
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30),
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isLoading ? null : _signInWithGoogle,
                              icon: Image.asset(
                                'assets/images/google_logo.png',
                                height: 24,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.login,
                                  color: cs.onSecondary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.secondary,
                                foregroundColor: cs.onSecondary,
                                minimumSize: Size(width - 60, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: TextStyle(
                                  fontSize: (width <= 550) ? 14 : 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                elevation: 4,
                                shadowColor: cs.secondary.withOpacity(0.5),
                              ),
                              label: const Text("Continue with Google"),
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => _controller.jumpToPage(
                                      _pageImages.length - 1),
                                  style: TextButton.styleFrom(
                                    foregroundColor: cs.primary,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: (width <= 550) ? 13 : 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  child: const Text("SKIP"),
                                ),
                                ElevatedButton(
                                  onPressed: () => _controller.nextPage(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.secondary,
                                    foregroundColor: cs.onSecondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    padding: (width <= 550)
                                        ? const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 16)
                                        : const EdgeInsets.symmetric(
                                            horizontal: 35, vertical: 20),
                                    textStyle: TextStyle(
                                      fontSize: (width <= 550) ? 13 : 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  child: const Text("NEXT"),
                                ),
                              ],
                            ),
                          ),

                    const SizedBox(height: 10),

                    // Institute tagline
                    Text(
                      'VIDYANJALI INSTITUTE OF\nEXCELLENCE & WONDER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            // ── LAYER 4 — Loading overlay ─────────────────────────────────
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: cs.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Signing in with Google...',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Auth helpers ──────────────────────────────────────────────────────────

  void _navigateAfterLogin(User user) async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (userData.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RootApp()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => CollectionForm(userId: user.uid)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Error: ${e.toString()}',
          color: Theme.of(context).colorScheme.error);
    }
  }

  void _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.signInwithGoogle();

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardLoader()),
        );
        _showSnackBar('Welcome ${user.displayName ?? "User"}!',
            color: Theme.of(context).colorScheme.primary);
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar('Sign in cancelled',
              color: Theme.of(context).colorScheme.secondary);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar('Sign in failed: ${e.toString()}',
          color: Theme.of(context).colorScheme.error);
    }
  }

  void _showSnackBar(String message, {required Color color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
