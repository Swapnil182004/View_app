import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_course/core/services/injection_container.dart';
import 'package:online_course/firebase_options.dart';
import 'package:online_course/src/features/course/pesentation/bloc/explore/course_bloc.dart';
import 'package:online_course/src/features/course/pesentation/bloc/favorite_course/favorite_course_bloc.dart';
import 'package:online_course/src/features/course/pesentation/bloc/feature/feature_course_bloc.dart';
import 'package:online_course/src/features/course/pesentation/bloc/recommend/recommend_course_bloc.dart';
import 'package:online_course/src/features/onboarding/presentation/onboarding_screen.dart';

// ✅ IMPORT THE NEW AUTH GATE
import 'package:online_course/src/features/login/presentation/auth_gate.dart';

import 'package:online_course/src/root_app.dart';
import 'package:online_course/src/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization: $e');
  }

  try {
    await initLocator();
    debugPrint('✅ Dependency injection initialized');
  } catch (e) {
    debugPrint('❌ DI initialization failed: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization Error: $e'),
        ),
      ),
    ));
    return;
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => locator.get<CourseBloc>(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => locator.get<FeatureCourseBloc>(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => locator.get<RecommendCourseBloc>(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => locator.get<FavoriteCourseBloc>(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VIEW Institute',
        themeMode: ThemeMode.system,
        theme: MaterialTheme(
          Typography.material2021().black,
        ).light(),
        darkTheme: MaterialTheme(
          Typography.material2021().white,
        ).dark(),

        // ✅ FIX: Dedicated Splash Screen for loading state
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Show custom splash screen while loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen(); // ✅ Custom splash
            }

            // ✅ CHANGED: If user is logged in, send them to the AuthGate!
            // AuthGate will check if they picked a syllabus before showing RootApp
            if (snapshot.hasData && snapshot.data != null) {
              return const AuthGate();
            }

            // If no user, show your intro sliders (OnboardingScreen)
            return const OnboardingScreen();
          },
        ),

        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

// ✅ NEW: Simple Splash Screen without white background
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor:
      const Color(0xFFE8ECF9), // Light emerald green (same as onboarding)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo - Large and visible without color tinting
            Image.asset(
              'assets/images/logo.png',
              height: 180,
              fit: BoxFit.contain,
              color: cs.primary,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'VIEW',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Loading indicator
            CircularProgressIndicator(
              color: cs.primary,
              strokeWidth: 3,
            ),

            const SizedBox(height: 40),

            // Institute name
            Text(
              'VIDYANJALI INSTITUTE OF\nEXCELLENCE & WONDER',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cs.primary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
