// lib/src/features/onboarding/presentation/onboarding_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_course/core/services/auth_service.dart';
import 'package:online_course/src/features/collection_form/collection_form.dart';
import 'package:online_course/src/root_app.dart';
import 'widgets/onboarding_contents.dart';
import 'package:online_course/src/features/onboarding/presentation/syllabus_setup_screen.dart';


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
  late Animation<double> _scaleAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize PageController immediately (lightweight)
    _controller = PageController();

    // Delay heavy animation initialization until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
      );

      _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutBack),
      );

      setState(() {
        _isInitialized = true;
      });

      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isInitialized) {
      _animationController.dispose();
    }
    super.dispose();
  }

  int _currentPage = 0;

  // ✅ Updated colors matching Emerald & Golden theme
  List<Color> colors = const [
    Color(0xFFE8ECF9), // Light emerald green
    Color(0xFFFFF9E6), // Light golden yellow
    Color(0xFFFAFAFA), // Off-white
  ];

  AnimatedContainer _buildDots({int? index}) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        color: _currentPage == index
            ? cs.primary // Emerald green when active
            : cs.onSurfaceVariant.withOpacity(0.3),
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: _currentPage == index ? 20 : 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Early return if widget is unmounted
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    final cs = Theme.of(context).colorScheme;

    // Show simple loading screen until animations are initialized
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: colors[0],
        body: Center(
          child: CircularProgressIndicator(
            color: cs.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors[_currentPage],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ✅ VIEW Logo WITHOUT white background
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        fit: BoxFit.contain,
                        color: cs.primary,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            width: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [cs.primary, cs.secondary],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'VIEW',
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Main content with PageView
                Expanded(
                  child: PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: _controller,
                    onPageChanged: (value) {
                      if (mounted) {
                        setState(() => _currentPage = value);
                      }
                    },
                    itemCount: contents.length,
                    itemBuilder: (context, i) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image with error handling
                              Image.asset(
                                contents[i].image,
                                height: height * 0.28,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: height * 0.28,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          cs.primary.withOpacity(0.2),
                                          cs.secondary.withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        i == 0
                                            ? Icons.school_outlined
                                            : i == 1
                                            ? Icons.menu_book_outlined
                                            : Icons.rocket_launch_outlined,
                                        size: 100,
                                        color: cs.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: (height >= 840) ? 40 : 20,
                              ),
                              Text(
                                contents[i].title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  fontWeight: FontWeight.bold,
                                  fontSize: (width <= 550) ? 26 : 32,
                                  color: cs.primary, // Emerald green
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                contents[i].desc,
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  fontWeight: FontWeight.w400,
                                  fontSize: (width <= 550) ? 15 : 22,
                                  color: cs.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: height * 0.02),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom section with dots and buttons
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          contents.length,
                              (int index) => _buildDots(index: index),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Buttons
                      _currentPage + 1 == contents.length
                          ? Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 30),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : signInwithGoogle,
                          icon: Image.asset(
                            'assets/images/google_logo.png',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.login,
                                color: cs.onSecondary,
                              );
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            cs.secondary, // Golden yellow
                            foregroundColor: cs.onSecondary, // Green text
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: (width <= 550)
                                ? const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 16)
                                : EdgeInsets.symmetric(
                                horizontal: width * 0.15,
                                vertical: 20),
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
                              onPressed: () {
                                _controller.jumpToPage(2);
                              },
                              style: TextButton.styleFrom(
                                elevation: 0,
                                foregroundColor: cs.primary, // Emerald
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: (width <= 550) ? 13 : 16,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              child: const Text("SKIP"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _controller.nextPage(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  curve: Curves.easeIn,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.secondary, // Golden
                                foregroundColor: cs.onSecondary, // Green
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                    ],
                  ),
                ),

                // Subtitle at bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 5),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'VIDYANJALI INSTITUTE OF\nEXCELLENCE & WONDER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: cs.primary, // Emerald green
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Loading indicator
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

  void navigete(User user) async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (userData.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RootApp()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CollectionForm(userId: user.uid)),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // ✅ UPDATED GOOGLE SIGN IN METHOD
  void signInwithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.signInwithGoogle();

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && mounted) {
        // 🟢 CRITICAL FIX: Force navigation to DashboardLoader right after Google Login!
        // This ensures they hit the Enrolment Check before accessing the main app.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardLoader()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${user.displayName ?? "User"}!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        // Sign in was cancelled or failed
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sign in cancelled'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
