import 'dart:async';
import 'package:flutter/material.dart';

class ExploreSearchBlock extends StatefulWidget {
  final Function(String) onSearch;

  const ExploreSearchBlock({Key? key, required this.onSearch}) : super(key: key);

  @override
  State<ExploreSearchBlock> createState() => _ExploreSearchBlockState();
}

class _ExploreSearchBlockState extends State<ExploreSearchBlock> {
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {});
          _onSearchChanged(value); // ✅ Auto-filter as the user types
        },
        onSubmitted: (value) {
          _debounce?.cancel(); // Cancel any pending search
          widget.onSearch(value); // Immediate search on Enter
        },
        decoration: InputDecoration(
          hintText: "Search courses (e.g. btech)",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF1E40AF),
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    _debounce?.cancel();
                    widget.onSearch("");
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
        ),
      ),
    );
  }
}
