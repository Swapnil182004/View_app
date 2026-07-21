import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:online_course/src/features/course/data/models/section.model.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/course_detail_bottom_block.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/course_detail_image.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/course_detail_info.dart';
import 'package:online_course/src/features/course/pesentation/pages/course_detail/widgets/section_card.dart';
import 'package:online_course/src/widgets/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({
    required this.course,
    this.isHero = false,
    Key? key,
    this.isPurchased = false,
    this.purchasedType = const [0],
    this.purchasedSections = const [],
    this.sectionPurchaseDate = const {}, required int initialTab,
  }) : super(key: key);
  
  final Course course;
  final bool isHero;
  final bool isPurchased;
  final List<int> purchasedType;
  final List<String> purchasedSections;
  final Map<String, Timestamp> sectionPurchaseDate;

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  Map<String, int> sections = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return LiquidPullToRefresh(
      color: const Color(0xFF1D4ED8), // 🔵 Standard Blue
      backgroundColor: cs.surface,
      showChildOpacityTransition: false,
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA), // ✅ Off-white background
        appBar: const CustomAppBar(title: "Course Details"),
        body: _buildBody(widget.course),
        bottomNavigationBar: !widget.isPurchased
            ? FutureBuilder(
                future: fetchSectionData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D4ED8), // 🔵 Standard Blue
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: const Text(
                        'Error securing price',
                        style: TextStyle(color: Color(0xFFE67E22)), // ✅ Orange error
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    return CourseDetailBottomBlock(
                      course: widget.course,
                      sectionList: snapshot.data as List<Section>,
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
            : null,
      ),
    );
  }

  Future<List<Section>> fetchSectionData() async {
    final data = await FirebaseFirestore.instance
        .collection('course_sections')
        .where('courseId', isEqualTo: widget.course.id.toString())
        .get();
    
    List<Section> sectionList = [];
    for (var element in data.docs) {
      sectionList.add(Section.fromJson(element.data()));
    }
    print(sectionList.map((e) => e.title).toList());
    return sectionList;
  }

  Widget _buildBody(Course course) {
    final cs = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image
          !widget.isPurchased
              ? CourseDetailImage(
                  course: course,
                  isHero: widget.isHero,
                )
              : const SizedBox(),
          const SizedBox(height: 15),
          
          // Course Info
          CourseDetailInfo(
            course: course,
          ),
          const SizedBox(height: 10),
          
          // Telegram Button (if purchased)
          if (widget.isPurchased)
            FutureBuilder(
              future: fetchTelegramLink(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: CircularProgressIndicator(
                        color: Color(0xFF1D4ED8), // 🔵 Standard Blue
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const SizedBox.shrink();
                }
                if (snapshot.hasData && (snapshot.data as String).isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1D4ED8), // 🔵 Blue
                          Color(0xFF5A81E8), // ✅ Light Emerald
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D4ED8).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          launchUrl(Uri.parse(snapshot.data as String));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.telegram,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Join Telegram Group',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          
          // Section Header - Always shown
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8ECF9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.list_alt_rounded,
                    color: Color(0xFF1A56DB),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Course Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(
            color: const Color(0xFFE0E0E0),
            thickness: 1,
            height: 20,
          ),
          
          // Section Cards - Always shown
          FutureBuilder(
            future: fetchSectionData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFFE67E22),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Error fetching course data',
                          style: TextStyle(
                            color: Color(0xFFE67E22),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (snapshot.hasData) {
                List<Section> sectionList = snapshot.data as List<Section>;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sectionList.length,
                  itemBuilder: (context, index) {
                    final section = sectionList[index];
                    
                    return SectionCard(
                      section: section,
                      courseId: course.id,
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<String> fetchTelegramLink() async {
    final dataSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('id', isEqualTo: widget.course.id)
        .get();
    
    if (dataSnapshot.docs.isNotEmpty) {
      var data = dataSnapshot.docs[0].data();
      return data['telegramGroupLink'] ?? '';
    }
    return '';
  }
}
