import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/document_viewer/presentation/pdf_viewer.dart';

class SectionTabNotes extends StatefulWidget {
  final int courseId;
  final String sectionId;

  const SectionTabNotes({
    Key? key,
    required this.courseId,
    required this.sectionId,
  }) : super(key: key);

  @override
  State<SectionTabNotes> createState() => _SectionTabNotesState();
}

class _SectionTabNotesState extends State<SectionTabNotes> {
  List<Map<String, dynamic>> _folders = [];
  Map<String, List<Map<String, dynamic>>> _folderNotes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Step 1: Fetch note_folders for this section
      QuerySnapshot folderSnapshot = await FirebaseFirestore.instance
          .collection('note_folders')
          .where('courseId', isEqualTo: widget.courseId)
          .where('sectionId', isEqualTo: widget.sectionId)
          .get();

      List<Map<String, dynamic>> folders = [];
      for (var doc in folderSnapshot.docs) {
        folders.add(doc.data() as Map<String, dynamic>);
      }

      // Step 2: Fetch notes for this section
      QuerySnapshot notesSnapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('courseId', isEqualTo: widget.courseId.toString())
          .where('sectionId', isEqualTo: widget.sectionId)
          .get();

      List<Map<String, dynamic>> allNotes = [];
      for (var doc in notesSnapshot.docs) {
        allNotes.add(doc.data() as Map<String, dynamic>);
      }

      // Group notes by folder name
      Map<String, List<Map<String, dynamic>>> folderMap = {};
      
      if (folders.isNotEmpty) {
        for (var folder in folders) {
          final folderName = folder['name'] as String? ?? 'Notes';
          folderMap[folderName] = allNotes;
        }
      } else if (allNotes.isNotEmpty) {
        folderMap['All Notes'] = allNotes;
      }

      setState(() {
        _folders = folders;
        _folderNotes = folderMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching notes: $e');
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

    if (_folderNotes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _folderNotes.entries.map((entry) {
        return _buildFolderCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildFolderCard(String folderName, List<Map<String, dynamic>> notes) {
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
                    color: const Color(0xFFE67E22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_special_rounded, color: Colors.white, size: 18),
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
                        '${notes.length} note${notes.length != 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Note items
          ...notes.map((note) => _buildNoteItem(note)),
        ],
      ),
    );
  }

  Widget _buildNoteItem(Map<String, dynamic> note) {
    final heading = note['heading'] as String? ?? 'Untitled';
    final details = note['details'] as String? ?? '';
    final pdfUrl = note['pdfUrl'] as String? ?? '';
    final hasPdf = pdfUrl.isNotEmpty;

    return InkWell(
      onTap: () {
        if (hasPdf) {
          AppNavigator.to(context, PdfViewer(url: pdfUrl));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description_rounded, color: Color(0xFF1A56DB), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heading,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (details.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                      ),
                    ),
                ],
              ),
            ),
            if (hasPdf)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 14, color: Colors.red),
                    SizedBox(width: 2),
                    Text('PDF', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
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
                color: const Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.note_alt_outlined, size: 48, color: Color(0xFFE67E22)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No notes available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Notes will appear here once added',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}