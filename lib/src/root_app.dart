import 'package:flutter/material.dart';
import 'package:online_course/core/utils/app_constant.dart';
import 'package:online_course/src/features/course/pesentation/pages/news/news_list_screen.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/quiz_page.dart';
import 'package:online_course/src/features/course/pesentation/pages/my_course/my_course.dart';
import 'package:online_course/src/theme/app_color.dart';
import 'package:online_course/src/widgets/bottombar_item.dart';
import 'features/course/pesentation/pages/home/home.dart';
import 'package:online_course/src/features/course/pesentation/pages/quiz/quiz_page.dart';
class RootApp extends StatefulWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  State<RootApp> createState() => RootAppState();
}

class RootAppState extends State<RootApp> with TickerProviderStateMixin {
  int _activeTab = 0;
  final List _barItems = [
    {
      "icon": "assets/icons/home.svg",
      "active_icon": "assets/icons/home.svg",
      "page": const HomePage(),
      "title": "Home",
    },
    {
      "icon": "assets/icons/play.svg",
      "active_icon": "assets/icons/play.svg",
      "page": const MyCoursePage(),
      "title": "My Course",
    },
    {
      "icon": "assets/icons/quiz.svg",
      "active_icon": "assets/icons/quiz.svg",
      "page": const QuizMainPage(),
      "title": "Quiz",
    },
    // ✅ REPLACED PYQ with NEWS
    {
      "icon": "assets/icons/newspaper.svg", // ✅ Add this icon to assets
      "active_icon": "assets/icons/newspaper.svg",
      "page": const NewsListScreen(),
      "title": "News",
    },
  ];

//====== set animation=====
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: AppConstant.animatedBodyMs),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  _buildAnimatedPage(page) {
    return FadeTransition(child: page, opacity: _animation);
  }

  // ✅ PUBLIC METHOD - Categories se navigation ke liye
  void onPageChanged(int index) {
    if (index == _activeTab) return;
    _controller.reset();
    setState(() {
      _activeTab = index;
    });
    _controller.forward();
  }

//====== end set animation=====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildPage(),
          _buildFloatingBottomBar(),
        ],
      ),
    );
  }

  Widget _buildPage() {
    return IndexedStack(
      index: _activeTab,
      children: List.generate(
        _barItems.length,
        (index) => _buildAnimatedPage(_barItems[index]["page"]),
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    // ✅ Get safe area padding to avoid system navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 20, // ✅ Add system nav bar height + spacing
      left: 20,
      right: 20,
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: _buildBottomIcon(),
      ),
    );
  }

  Widget _buildBottomIcon() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 25,
        right: 25,
        top: 7,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          _barItems.length,
          (index) => BottomBarItem(
            _barItems[index]["icon"],
            isActive: _activeTab == index,
            activeColor: Colors.white,
            onTap: () {
              onPageChanged(index);
            },
            title: _barItems[index]["title"] ?? "",
          ),
        ),
      ),
    );
  }
}
