import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/section.model.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_tab_lessons.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_tab_notes.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_tab_exercises.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_tab_online_classes.dart';

class SectionContentTabs extends StatefulWidget {
  final int courseId;
  final Section section;

  const SectionContentTabs({
    Key? key,
    required this.courseId,
    required this.section,
  }) : super(key: key);

  @override
  State<SectionContentTabs> createState() => _SectionContentTabsState();
}

class _SectionContentTabsState extends State<SectionContentTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sectionId = widget.section.deriveSectionId(widget.courseId);

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE8ECF9), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab Bar - Horizontally scrollable
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF1A56DB),
              unselectedLabelColor: const Color(0xFF757575),
              indicatorColor: const Color(0xFF1A56DB),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline, size: 16),
                      SizedBox(width: 4),
                      Text("Lessons"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.note_alt_outlined, size: 16),
                      SizedBox(width: 4),
                      Text("Notes"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_outlined, size: 16),
                      SizedBox(width: 4),
                      Text("Exercises"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_outlined, size: 16),
                      SizedBox(width: 4),
                      Text("Online Class"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content using IndexedStack for proper rendering in scrollable
          IndexedStack(
            index: _tabController.index,
            children: [
              // Lessons Tab
              SectionTabLessons(
                courseId: widget.courseId,
                sectionId: sectionId,
              ),
              // Notes Tab
              SectionTabNotes(
                courseId: widget.courseId,
                sectionId: sectionId,
              ),
              // Exercises Tab
              SectionTabExercises(
                courseId: widget.courseId,
                sectionId: sectionId,
              ),
              // Online Classes Tab
              SectionTabOnlineClasses(
                courseId: widget.courseId,
                sectionId: sectionId,
              ),
            ],
          ),
        ],
      ),
    );
  }
}