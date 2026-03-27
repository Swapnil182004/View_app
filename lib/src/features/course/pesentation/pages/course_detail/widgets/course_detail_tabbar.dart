import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/section.model.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/course_detail_lesson_list.dart';

class CourseDetailTabBar extends StatefulWidget {
  final int courseId;
  final bool isPurchased;
  final List<int> purchaseType;
  final List<String> purchasedSections;
  final List<Section> sectionList;
  final Map<String, int> sections;
  final Map<String, Timestamp> sectionPurchaseDate;
  
  const CourseDetailTabBar({
    super.key,
    required this.courseId,
    this.isPurchased = false,
    required this.sections,
    this.purchaseType = const [0],
    required this.sectionList,
    this.purchasedSections = const [],
    this.sectionPurchaseDate = const {},
  });

  @override
  State<CourseDetailTabBar> createState() => _CourseDetailTabBarState();
}

class _CourseDetailTabBarState extends State<CourseDetailTabBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    print(
        'got sectionlist in tabbar ${widget.sectionList.map((e) => e.title).toList()}');
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildTabBar(), _buildTabBarPages()],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: const Color(0xFF1A56DB), // ✅ Emerald when selected
        unselectedLabelColor: const Color(0xFF757575), // ✅ Gray when unselected
        isScrollable: false,
        indicatorColor: const Color(0xFF1A56DB), // ✅ Emerald indicator
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_circle_outline, size: 20),
                SizedBox(width: 6),
                Text("Lessons"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.article_outlined, size: 20),
                SizedBox(width: 6),
                Text("Exercises"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarPages() {
    return Container(
      constraints: const BoxConstraints(minHeight: 150, maxHeight: 350),
      width: double.infinity,
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          // Lessons Tab
          Container(
            constraints: const BoxConstraints(minHeight: 150, maxHeight: 350),
            width: double.infinity,
            child: CourseDetailLessonList(
              purchaseType: widget.purchaseType,
              isPurchased: widget.isPurchased,
              courseId: widget.courseId,
              sections: widget.sections,
              purchasedSections: widget.purchasedSections,
              sectionPurchaseDate: widget.sectionPurchaseDate,
              type: 2,
              sectionlist: widget.sectionList,
            ),
          ),
          
          // Exercises Tab
          Container(
            constraints: const BoxConstraints(minHeight: 150, maxHeight: 350),
            width: double.infinity,
            child: CourseDetailLessonList(
              purchaseType: widget.purchaseType,
              isPurchased: widget.isPurchased,
              courseId: widget.courseId,
              sections: widget.sections,
              purchasedSections: widget.purchasedSections,
              sectionPurchaseDate: widget.sectionPurchaseDate,
              type: 1,
              sectionlist: widget.sectionList,
            ),
          )
        ],
      ),
    );
  }
}
