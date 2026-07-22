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
  // Track expanded folder ids
  final Set<String> _expandedFolderIds = {};

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

      // Step 2: Fetch video lessons for this course + section (collection: lesson_videos)
      QuerySnapshot lessonSnapshot = await FirebaseFirestore.instance
          .collection('lesson_videos')
          .where('courseId', isEqualTo: widget.courseId)
          .where('sectionId', isEqualTo: widget.sectionId)
          .get();

      List<Map<String, dynamic>> allLessons = [];
      for (var doc in lessonSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        allLessons.add(data);
      }

      // Step 3: Group lessons by folderId (if no folders, put in 'all')
      Map<String, List<Map<String, dynamic>>> folderMap = {};

      if (folders.isEmpty) {
        folderMap['all'] = allLessons;
      } else {
        for (var folder in folders) {
          final folderId = folder['docId'] as String;
          folderMap[folderId] = [];
        }

        for (var lesson in allLessons) {
          final folderId = (lesson['folderId'] ?? lesson['folder_id'] ?? lesson['folder']) as String?;
          if (folderId != null && folderMap.containsKey(folderId)) {
            folderMap[folderId]!.add(lesson);
          } else {
            // put unassigned lessons under 'all'
            folderMap.putIfAbsent('all', () => []).add(lesson);
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

    if ((_folders.isEmpty || _folderLessons.isEmpty) && _folderLessons['all'] == null) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // If there are no explicit folders, show all lessons as cards
        if (_folders.isEmpty && (_folderLessons['all'] ?? []).isNotEmpty)
          ..._buildLessonItems(_folderLessons['all'] ?? [])
        else
          ..._folders.map((folder) {
            final folderName = folder['name'] as String? ?? 'Folder';
            final folderId = folder['docId'] as String;
            final lessons = _folderLessons[folderId] ?? [];
            final isExpanded = _expandedFolderIds.contains(folderId) || (_expandedFolderIds.isEmpty && folder == _folders.first);
            return _buildFolderCard(folderId, folderName, lessons, isExpanded);
          }),
      ],
    );
  }
  Widget _buildFolderCard(String folderId, String folderName, List<Map<String, dynamic>> lessons, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF9)),
      ),
      child: Column(
        children: [
          // Folder Header (tappable to expand/collapse)
          InkWell(
            onTap: () {
              setState(() {
                if (_expandedFolderIds.contains(folderId)) {
                  _expandedFolderIds.remove(folderId);
                } else {
                  _expandedFolderIds.add(folderId);
                }
              });
            },
            child: Container(
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
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _expandedFolderIds.contains(folderId) ? 0.5 : 0.0,
                    child: const Icon(Icons.expand_more_rounded, color: Color(0xFF1A56DB)),
                  ),
                ],
              ),
            ),
          ),

          // Expanded lessons list
          if (_expandedFolderIds.contains(folderId))
            ...lessons.map((lesson) => _buildLessonItem(lesson))
          else if (folderId == 'all' && (lessons.isNotEmpty))
            ...lessons.map((lesson) => _buildLessonItem(lesson)),
        ],
      ),
    );
  }

  List<Widget> _buildLessonItems(List<Map<String, dynamic>> lessons) {
    return lessons.map((lesson) => _buildLessonItem(lesson)).toList();
  }

  Widget _buildLessonItem(Map<String, dynamic> lesson) {
    final name = (lesson['name'] ?? lesson['title']) as String? ?? 'Untitled';
    final duration = (lesson['duration'] ?? lesson['timing']) as String? ?? '';
    final image = (lesson['image'] ?? lesson['thumbnail'] ?? lesson['thumbnail_url']) as String? ?? '';
    final videoUrl = (lesson['video_url'] ?? lesson['videoUrl'] ?? lesson['video']) as String? ?? '';

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