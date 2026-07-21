import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/document_viewer/presentation/pdf_viewer.dart';

class SectionTabExercises extends StatefulWidget {
  final int courseId;
  final String sectionId;

  const SectionTabExercises({
    Key? key,
    required this.courseId,
    required this.sectionId,
  }) : super(key: key);

  @override
  State<SectionTabExercises> createState() => _SectionTabExercisesState();
}

class _SectionTabExercisesState extends State<SectionTabExercises> {
  List<Map<String, dynamic>> _folders = [];
  Map<String, List<Map<String, dynamic>>> _folderExercises = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Step 1: Fetch exercise_folders for this section
      QuerySnapshot folderSnapshot = await FirebaseFirestore.instance
          .collection('exercise_folders')
          .where('courseId', isEqualTo: widget.courseId)
          .where('sectionId', isEqualTo: widget.sectionId)
          .get();

      List<Map<String, dynamic>> folders = [];
      for (var doc in folderSnapshot.docs) {
        folders.add(doc.data() as Map<String, dynamic>);
      }

      // Step 2: Fetch exercises for this section
      QuerySnapshot exerciseSnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .where('courseId', isEqualTo: widget.courseId)
          .where('sectionId', isEqualTo: widget.sectionId)
          .get();

      List<Map<String, dynamic>> allExercises = [];
      for (var doc in exerciseSnapshot.docs) {
        allExercises.add(doc.data() as Map<String, dynamic>);
      }

      // Group by folder
      Map<String, List<Map<String, dynamic>>> folderMap = {};
      
      if (folders.isNotEmpty) {
        for (var folder in folders) {
          final folderName = folder['name'] as String? ?? 'Exercises';
          folderMap[folderName] = allExercises;
        }
      } else if (allExercises.isNotEmpty) {
        folderMap['All Exercises'] = allExercises;
      }

      setState(() {
        _folders = folders;
        _folderExercises = folderMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
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

    if (_folderExercises.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _folderExercises.entries.map((entry) {
        return _buildFolderCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildFolderCard(String folderName, List<Map<String, dynamic>> exercises) {
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
                    color: const Color(0xFF388E3C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 18),
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
                        '${exercises.length} exercise${exercises.length != 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Exercise items
          ...exercises.map((exercise) => _buildExerciseItem(exercise)),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(Map<String, dynamic> exercise) {
    final name = exercise['name'] as String? ?? 'Untitled';
    final duration = exercise['duration'] as String? ?? '';
    final image = exercise['image'] as String? ?? '';
    // exercises store PDF URLs in video_url field
    final pdfUrl = exercise['video_url'] as String? ?? '';
    final hasPdf = pdfUrl.isNotEmpty;

    return InkWell(
      onTap: () {
        if (hasPdf) {
          AppNavigator.to(context, PdfViewer(url: pdfUrl));
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
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                image: image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: image.isEmpty
                  ? const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28)
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
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF9E9E9E)),
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
            if (hasPdf)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_rounded, size: 14, color: Color(0xFF388E3C)),
                    SizedBox(width: 2),
                    Text('PDF', style: TextStyle(fontSize: 11, color: Color(0xFF388E3C), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
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
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined, size: 48, color: Color(0xFF388E3C)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No exercises available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Exercises will appear here once added',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}