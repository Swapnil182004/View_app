import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/pesentation/pages/explore/widgets/explore_appbar.dart';
import 'package:online_course/src/features/course/pesentation/pages/explore/widgets/explore_course_list.dart';
import 'package:online_course/src/features/course/pesentation/pages/explore/widgets/explore_search_block.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String selectedCategory = "";
  String searchTxt = "";

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      color: const Color(0xFF1A56DB), // ✅ Primary Blue
      backgroundColor: Colors.white,
      showChildOpacityTransition: false,
      onRefresh: () async {
        setState(() {
          selectedCategory = "";
          searchTxt = "";
        });
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white), // ✅ Back button white
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              pinned: true,
              snap: true,
              floating: true,
              title: const ExploreAppbar(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: ExploreSearchBlock(
                  onSearch: (String s) {
                    setState(() {
                      searchTxt = s;
                    });
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            ExploreCourseList(
              searchText: searchTxt,
              selectedCategory: selectedCategory,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
