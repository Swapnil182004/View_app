import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:online_course/src/features/pyq/presentation/pages/chat/widgets/chat_search_block.dart';

import 'exam_wise_pyq_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool showUnlockButton = true;
  
  String searchTxt = "";
  String selectedCategory = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: () async {
        setState(() {
          searchTxt = "";
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          toolbarHeight: 60, // Reduced height limits vertical space heavily
          leadingWidth: 40,  // Prevents leading from stretching AppBar past 30px
          backgroundColor: const Color(0xFF1E40AF), // Brand Blue
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Turn off default back button to avoid its 48x48 min constraints
          leading: Align(
            alignment: Alignment.center,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          centerTitle: false,
          titleSpacing: 0, // Closes the gap between back button and title
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E40AF), Color(0xFF60A5FA)],
              ),
            ),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Forces perfect vertical alignment in the tight space
            children: [
              Container(
                padding: const EdgeInsets.all(4), // Tight padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 18, // Tiny icon for 30px line height
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Exam-wise PYQ',
                style: TextStyle(
                  fontSize: 18, // Slim font
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                  height: 1.0, // Removes extra line height padding
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // ✅ Search bar immediately follows AppBar
            Container(
              padding: const EdgeInsets.all(16),
              child: ChatSearchBlock(
                onSearch: (String s) async {
                  setState(() {
                    searchTxt = s;
                  });
                },
              ),
            ),
            // ✅ "All Available subjects" title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "All Available subjects",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A56DB), // Brand Blue
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ✅ Then the list of all available subjects (ExamsPage)
            Expanded(
              child: ExamsPage(
                searchedText: searchTxt,
                selectedCategory: selectedCategory, // This is always empty now, or you could pass an empty string
              ),
            ),
          ],
        ),
      ),
    );
  }
}
