import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/video/presentation/screen/yotutube_player.dart';

class SectionTabLessons extends StatefulWidget {
  final int courseId;
  final String sectionId;

  const SectionTabLessons({
    Key? key,
    required this.courseId,
    required this.sectionId,
  }) : super(key: key);

  @override
  State<SectionTabLessons> createState() => _SectionTabLessonsState();
}

class _SectionTabLessonsState extends State<SectionTabLessons> {
  List<Map<String, dynamic>> _folders = [];
  Map<String, List<Map<String, dynamic>>> _folderLessons = {};
  bool _isLoading = true;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Step 1: Fetch lesson_folders for this section
      QuerySnapshot folderSnapshot = await FirebaseFirestore.instance
          .collection('lesson_folders')
          .where('courseId', isEqualTo: widget.courseId)
          .where('sectionId', isEqualTo: widget.sectionId)
          .get();

      List<Map<String, dynamic>> folders = [];
      for (var doc in folderSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        folders.add(data);
      }

      // Step 2: Fetch lessons for this course + section
      QuerySnapshot lessonSnapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .where('courseId', isEqualTo: widget.courseId)
          .where('sectionId', isEqualTo: widget.sectionId)
          .get();

      List<Map<String, dynamic>> allLessons = [];
      for (var doc in lessonSnapshot.docs) {
        allLessons.add(doc.data() as Map<String, dynamic>);
      }

      // Step 3: Group lessons by folder name
      Map<String, List<Map<String, dynamic>>> folderMap = {};
      
      // If no folders exist, put all lessons under "All Lessons"
      if (folders.isEmpty && allLessons.isNotEmpty) {
        folderMap['All Lessons'] = allLessons;
      } else {
        // Put lessons in their respective folders
        for (var folder in folders) {
          final folderName = folder['name'] as String? ?? 'Folder';
          // Match lessons: if lesson has no direct folder field, show all under each folder
          folderMap[folderName] = allLessons;
          break; // Show all lessons once since lessons don't have a folder field directly
        }
        // If folder exists but no entries yet
        if (folderMap.isEmpty) {
          for (var folder in folders) {
            folderMap[folder['name'] as String? ?? 'Folder'] = allLessons;
          }
        }
      }

      setState(() {
        _folders = folders;
        _folderLessons = folderMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Color(0xFF1A56DB)),
        ),
      );
    }

    if (_folders.isEmpty && _folderLessons.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_folders.isEmpty && _folderLessons.isNotEmpty)
          ..._buildLessonItems(_folderLessons.values.first)
        else
          ..._folders.map((folder) {
            final folderName = folder['name'] as String? ?? 'Folder';
            final lessons = _folderLessons[folderName] ?? [];
            return _buildFolderCard(folderName, lessons, folder == _folders.first);
          }),
      ],
    );
  }

  Widget _buildFolderCard(String folderName, List<Map<String, dynamic>> lessons, bool defaultExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF9)),
      ),
      child: Column(
        children: [
          // Folder Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folderName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '${lessons.length} video${lessons.length != 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'Play All',
                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lesson items
          ...lessons.map((lesson) => _buildLessonItem(lesson)),
        ],
      ),
    );
  }

  List<Widget> _buildLessonItems(List<Map<String, dynamic>> lessons) {
    return lessons.map((lesson) => _buildLessonItem(lesson)).toList();
  }

  Widget _buildLessonItem(Map<String, dynamic> lesson) {
    final name = lesson['name'] as String? ?? 'Untitled';
    final duration = lesson['duration'] as String? ?? '';
    final image = lesson['image'] as String? ?? '';
    final videoUrl = lesson['video_url'] as String? ?? '';

    return InkWell(
      onTap: () {
        if (videoUrl.contains('youtube') || videoUrl.contains('youtu.be')) {
          AppNavigator.to(
            context,
            YotutubePlayer(url: videoUrl),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No video URL available')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
                image: image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: image.isEmpty
                  ? const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF1A56DB), size: 28)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (duration.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF1A56DB), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.video_library_outlined, size: 48, color: Color(0xFF1A56DB)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No lessons available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lessons will appear here once added',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}