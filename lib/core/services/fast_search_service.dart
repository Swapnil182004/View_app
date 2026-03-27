import 'package:firebase_database/firebase_database.dart' as db;

Future<List<String>> getDocIdsBySearchTerm(String searchTerm,String typeS) async {
    db.DatabaseReference ref = db.FirebaseDatabase.instance.ref('fastSearch');

    final query = ref
        .orderByChild('text')
        .startAt(searchTerm.toLowerCase())
        .endAt('${searchTerm.toLowerCase()}\uf8ff');

    final snapshot = await query.get();
    final docIds = <String>[];

    for (final childSnapshot in snapshot.children) {
      final type = childSnapshot.child('type').value as String;

      if (type == typeS) {
        final docId = childSnapshot.child('id').value as String;
        docIds.add(docId);
      }
    }

  
    return docIds;
  }
