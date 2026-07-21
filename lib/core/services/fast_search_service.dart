import 'package:firebase_database/firebase_database.dart' as db;

Future<List<String>> getDocIdsBySearchTerm(String searchTerm, String typeS) async {
  db.DatabaseReference ref = db.FirebaseDatabase.instance.ref('fastSearch');
  
  // Normalizing: Lowercase, trim, and remove dots (e.g. "b.tech" -> "btech")
  searchTerm = searchTerm.toLowerCase().trim().replaceAll(".", "");

  if (searchTerm.isEmpty) return [];

  // Split search term into keywords (e.g. "btech informatics")
  List<String> keywords = searchTerm.split(RegExp(r'\s+'));
  
  // Store a list of sets, where each set represents doc IDs for one keyword.
  List<Set<String>> keywordResultSets = [];

  // Limited to the first 3 keywords if many are provided
  int keywordsToProcess = keywords.length > 3 ? 3 : keywords.length;

  for (int i = 0; i < keywordsToProcess; i++) {
    // Normalizing each word (removing dots again just in case)
    String word = keywords[i].replaceAll(".", "");
    if (word.isEmpty) continue; // Skip empty strings

    final Set<String> currentWordDocIds = {};
    final query = ref
        .orderByChild('text')
        .startAt(word)
        .endAt('$word\uf8ff')
        .limitToFirst(100); 

    final snapshot = await query.get();

    for (final childSnapshot in snapshot.children) {
      final type = childSnapshot.child('type').value as String;
      if (type == typeS) {
        final docId = childSnapshot.child('id').value as String;
        currentWordDocIds.add(docId);
      }
    }
    
    if (currentWordDocIds.isNotEmpty) {
      keywordResultSets.add(currentWordDocIds);
    } else {
      // If one keyword has NO matches, then the entire intersection (AND) is empty.
      return [];
    }
  }

  if (keywordResultSets.isEmpty) {
    return [];
  }

  // Find doc IDs that appear in ALL result sets
  Set<String> intersection = keywordResultSets[0];
  for (int i = 1; i < keywordResultSets.length; i++) {
    intersection = intersection.intersection(keywordResultSets[i]);
  }

  return intersection.toList();
}
