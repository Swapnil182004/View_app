import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/course_lessons.dart';
import 'package:online_course/src/features/course/data/models/section.model.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/lesson_item.dart';

class CourseDetailLessonList extends StatefulWidget {
  CourseDetailLessonList({
    super.key,
    this.isPurchased = false,
    required this.courseId,
    required this.sections,
    this.purchaseType = const [0],
    required this.type,
    required this.sectionlist,
    this.purchasedSections = const [],
    this.sectionPurchaseDate = const {},
  });

  final bool isPurchased;
  final int courseId;
  final int type; //2 = video, 1 = exercise
  final Map<String, int> sections;
  final List<Section> sectionlist;
  List<int> purchaseType = [0];
  final List<String> purchasedSections;
  final Map<String, Timestamp> sectionPurchaseDate;

  @override
  State<CourseDetailLessonList> createState() =>
      _CourseDetailLessonListState();
}

class _CourseDetailLessonListState extends State<CourseDetailLessonList> {
  String selectedSection = "";
  List<CourseLessons> lessonList = [];

  @override
  void initState() {
    if (selectedSection.isEmpty) {
      selectedSection = widget.courseId.toString() + "all";
    }
    print(
        'selected section $selectedSection from section list in detail lessonlist ${widget.sectionlist.map((e) => e.title).toList()} and purchased is ${widget.isPurchased} and is ${widget.purchasedSections.map((e) => e.toString()).toList()}');
    fetchLessons(selectedSection);
    print(
        "purchased sections are ${widget.purchasedSections} and currently selected is $selectedSection");
    super.initState();
  }

  void fetchLessons(String sectionId) async {
    try {
      lessonList.clear();
      QuerySnapshot snapshot;
      if (widget.type == 2) {
        snapshot = await FirebaseFirestore.instance
            .collection('lessons')
            .where('courseId', isEqualTo: widget.courseId)
            .orderBy('name', descending: true)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('exercises')
            .where('courseId', isEqualTo: widget.courseId)
            .orderBy('name', descending: true)
            .get();
      }

      List<CourseLessons> lessonsExercisesList = [];

      for (var doc in snapshot.docs) {
        CourseLessons lesson =
            CourseLessons.fromJson(doc.data() as Map<String, dynamic>);
        if (lesson.sectionId == sectionId ||
            selectedSection == widget.courseId.toString() + "all") {
          lessonsExercisesList.add(lesson);
        }
      }

      setState(() {
        lessonList = lessonsExercisesList;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Section Selector - Horizontal Scroll
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: widget.sectionlist.length,
            itemBuilder: (context, index) {
              String sectionName = widget.sectionlist.toList()[index].title;
              String sectionId = widget.courseId.toString() +
                  widget.sectionlist.toList()[index].title.toLowerCase();

              bool isSelected = sectionId == selectedSection;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSection = sectionId;
                    print("now selected section is :" + sectionId);
                    fetchLessons(sectionId);
                  });
                  print(sectionId);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      // ✅ Emerald gradient when selected
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF1A56DB), // Emerald
                                Color(0xFF5A81E8), // Light Emerald
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A56DB)
                            : const Color(0xFFE0E0E0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1A56DB).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        sectionName,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white // ✅ White on emerald gradient
                              : const Color(0xFF757575), // ✅ Gray when unselected
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Lessons List
        Expanded(
          child: lessonList.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: lessonList.length,
                  itemBuilder: (context, index) {
                    return LessonItem(
                      data: lessonList[index],
                      clickable: widget.isPurchased &&
                          !CheckIfExpired(widget.purchasedSections.contains(
                                  widget.courseId.toString() + "all")
                              ? widget.courseId.toString() + "all"
                              : lessonList[index].sectionId) &&
                          (widget.purchasedSections.contains(selectedSection) ||
                              widget.purchasedSections
                                  .contains(widget.courseId.toString() + "all")),
                      type: widget.type,
                    );
                  },
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.type == 2
                                ? Icons.video_library_outlined
                                : Icons.article_outlined,
                            size: 48,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${widget.type == 2 ? "lessons" : "exercises"} available',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for updates',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        )
      ],
    );
  }

  bool CheckIfExpired(String sectionId) {
    if (widget.sectionPurchaseDate[sectionId] == null) {
      return true;
    }
    Timestamp timestamp = widget.sectionPurchaseDate[sectionId]!;
    DateTime timestampDate = timestamp.toDate();
    DateTime currentDate = DateTime.now();
    int differenceInDays = currentDate.difference(timestampDate).inDays;

    if (differenceInDays >= 30) {
      return true;
    } else {
      return false;
    }
  }
}
