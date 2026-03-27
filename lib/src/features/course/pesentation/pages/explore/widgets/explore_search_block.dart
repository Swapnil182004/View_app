import 'package:flutter/material.dart';
import 'package:online_course/src/widgets/custom_textfield.dart';
import 'package:online_course/src/widgets/icon_box.dart';

class ExploreSearchBlock extends StatefulWidget {
  final Function(String) onSearch;

  const ExploreSearchBlock({Key? key, required this.onSearch}) : super(key: key);

  @override
  State<ExploreSearchBlock> createState() => _ExploreSearchBlockState();
}

class _ExploreSearchBlockState extends State<ExploreSearchBlock> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Row(
        children: [
          Expanded(
            child: CustomTextBox(
              controller: _searchController,
              hint: "Search courses...",
              prefix: const Icon(
                Icons.search,
                color: Color(0xFF757575), // ✅ Secondary text color
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconBox(
            bgColor: const Color(0xFF1D4ED8), // 🔵 Standard Blue button
            radius: 10,
            onTap: () {
              widget.onSearch(_searchController.text);
            },
            child: const Icon(
              Icons.search,
              color: Color(0xFF1D4ED8), // 🔵 Blue icon on button
            ),
          )
        ],
      ),
    );
  }
}
