import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/section.model.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_tab_lessons.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_tab_notes.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_tab_exercises.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_tab_online_classes.dart';

class SectionDetailPage extends StatefulWidget {
  final Section section;
  final int courseId;

  const SectionDetailPage({
    Key? key,
    required this.section,
    required this.courseId,
  }) : super(key: key);

  @override
  State<SectionDetailPage> createState() => _SectionDetailPageState();
}

class _SectionDetailPageState extends State<SectionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sectionId = widget.section.deriveSectionId(widget.courseId);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          widget.section.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A56DB),
        elevation: 1,
        bottom: TabBar(
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
      body: TabBarView(
        controller: _tabController,
        children: [
          SectionTabLessons(
            courseId: widget.courseId,
            sectionId: sectionId,
          ),
          SectionTabNotes(
            courseId: widget.courseId,
            sectionId: sectionId,
          ),
          SectionTabExercises(
            courseId: widget.courseId,
            sectionId: sectionId,
          ),
          SectionTabOnlineClasses(
            courseId: widget.courseId,
            sectionId: sectionId,
          ),
        ],
      ),
    );
  }
}