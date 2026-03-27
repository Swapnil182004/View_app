import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/models/cur.model.dart';
import 'package:online_course/src/features/course/pesentation/pages/my_course/widgets/my_course_appbar.dart';
import 'package:online_course/src/features/course/pesentation/pages/my_course/widgets/my_course_progress_course_list.dart';

class MyCoursePage extends StatefulWidget {
  const MyCoursePage({Key? key}) : super(key: key);

  @override
  State<MyCoursePage> createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<List<course_user_relation>> getMycourses() async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      final purchasedCoursesSnapshot = await FirebaseFirestore.instance
          .collection('user_course_relation')
          .where('userId', isEqualTo: user?.uid ?? "me")
          .orderBy('purchase_date')
          .get();

      List<course_user_relation> courseUserRelations = [];
      for (var doc in purchasedCoursesSnapshot.docs) {
        courseUserRelations.add(course_user_relation.fromJson(doc.data()));
      }

      // ✅ Safely check if the list has items before calling .first
      if (courseUserRelations.isNotEmpty) {
        print('purchased course sections are ${courseUserRelations.first.sections.map((e) => e.toString()).toList()}');
      } else {
        print('User has no purchased courses.');
      }

      return courseUserRelations;

    } catch (e) {
      // ✅ This will print the exact Firebase rule or index error to your terminal!
      print("🔥 Firestore Fetch Error: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            _buildSilverAppbar(),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            children: <Widget>[
              FutureBuilder(
                future: getMycourses(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<course_user_relation>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: const Color(0xFF1D4ED8), // 🔵 Standard Blue
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(context);
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return MyCourseProgressCourseList(
                    myProgressCourses: snapshot.data!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSilverAppbar() {
    return SliverAppBar(
      pinned: true,
      snap: true,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF60A5FA)], // Deep Blue to Light Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: MyCourseAppBar(
        onPressed: () {
          setState(() {});
        },
      ),
      bottom: TabBar(
        controller: tabController,
        indicatorColor: Colors.white, // ✅ White indicator instead of orange
        indicatorWeight: 3,
        unselectedLabelColor: Colors.white70, // ✅ Light white for unselected
        labelColor: Colors.white, // ✅ White for selected
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: "My courses"),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE8ECF9), // ✅ Very light emerald
                    Color(0xFFFFF9E6), // ✅ Very light golden
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 64,
                color: Color(0xFF1A56DB), // 🔵 Brand Blue
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Courses Yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A), // ✅ Dark text
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Start learning by purchasing your first course!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575), // ✅ Secondary text
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE67E22), // ✅ Orange error (not red!)
            ),
            const SizedBox(height: 16),
            const Text(
              "Something went wrong",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please try again later",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
