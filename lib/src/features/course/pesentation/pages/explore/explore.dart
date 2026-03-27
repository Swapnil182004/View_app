import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/pesentation/pages/explore/widgets/explore_appbar.dart';
import 'package:online_course/src/features/course/pesentation/pages/explore/widgets/explore_category.dart';
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
              title: ExploreAppbar(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildBody(),
                childCount: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExploreSearchBlock(
            onSearch: (String s) {
              setState(() {
                searchTxt = s;
              });
            },
          ),
          const SizedBox(height: 15),
          ExploreCategory(
            onCategorySelected: (String c) {
              setState(() {
                selectedCategory = c;
              });
            },
          ),
          const SizedBox(height: 15),
          ExploreCourseList(
            searchText: searchTxt,
            selectedCategory: selectedCategory,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
