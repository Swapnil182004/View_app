import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_course/core/utils/app_navigate.dart';

// ✅ IMPORT THE DASHBOARD LOADER INSTEAD OF AUTH GATE
import 'package:online_course/src/features/onboarding/presentation/syllabus_setup_screen.dart';

import 'package:online_course/src/features/course/pesentation/pages/explore/explore.dart';
import 'package:online_course/src/features/course/pesentation/pages/news/news_list_screen.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/quiz_page.dart';
import 'package:online_course/src/features/course/pesentation/pages/my_course/my_course.dart';
import 'package:online_course/src/features/pyq/presentation/pages/chat/chat.dart';
import 'package:online_course/src/features/store/presentation/pages/ecommerce_page.dart';
import 'package:online_course/src/features/store/data/sourse/product_datasource.dart';
import 'package:online_course/src/features/store/data/repository/product_repository.dart';
import 'package:online_course/src/features/account/presentation/pages/account/account.dart';
import 'category_box.dart';

class HomeCategory extends StatelessWidget {
  const HomeCategory({required this.categories, super.key, required void Function(int tabIndex) onCategoryTap});

  final List categories;

  void _handleNavigation(BuildContext context, String name) {
    switch (name.toUpperCase()) {
      case "ALL":
        return;

      case "DASHBOARD":
      // ✅ NOW ROUTES TO DashboardLoader() TO PREVENT THE LOOP!
        AppNavigator.to(context, const DashboardLoader());
        break;

      case "SUBJECT":
        AppNavigator.to(context, const ExplorePage());
        break;
      case "LIVE CLASS":
      case "LIVE COURSE":
        AppNavigator.to(context, const MyCoursePage());
        break;
      case "PYQ":
        AppNavigator.to(context, const ChatPage());
        break;
      case "SYLLABUS":
        AppNavigator.to(context, const MyCoursePage());
        break;
      case "QUIZ":
        AppNavigator.to(context,  QuizMainPage());
        break;
      case "MY COURSE":
        AppNavigator.to(context, const MyCoursePage());
        break;
      case "EXPLORE":
        AppNavigator.to(context, const ExplorePage());
        break;
      case "NEWS":
        AppNavigator.to(context, const NewsListScreen());
        break;
      case "STORE":
        AppNavigator.to(context, ECommerceScreen(
            productRepository: ProductRepository(ProductDataSource(FirebaseFirestore.instance))
        ));
        break;
      case "ACCOUNT":
        AppNavigator.to(context, const AccountPage());
        break;
      default:
        AppNavigator.to(context, const ExplorePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
              (index) {
            final item = categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: CategoryBox(
                selectedColor: cs.primary,
                data: item,
                onTap: () => _handleNavigation(context, item["name"]),
              ),
            );
          },
        ),
      ),
    );
  }
}
