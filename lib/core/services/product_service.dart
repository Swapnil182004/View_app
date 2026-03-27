import 'package:cloud_firestore/cloud_firestore.dart';

import '../../src/features/store/data/model/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) {
    return _firestore.collection('products').add({
      'title': product.title,
      'subtitle': product.subtitle,
      'image_url': product.imageUrl,
    });
  }
    Future<List<QueryDocumentSnapshot>> getProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    return snapshot.docs;
  }
  Future<void> remove (String productId) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .delete();
  }

  Future<List<QueryDocumentSnapshot>> getParts(String productId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('products')
        .doc(productId)
        .collection('parts')
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getDocuments(String productId, String partId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('products')
        .doc(productId)
        .collection('parts')
        .doc(partId)
        .collection('documents')
        .get();
    return snapshot.docs;
  }

  // Future<void> addExam(String title, String description, DateTime uploadDate) async {
  //   final snapshot= await _firestore.collection('products').add({
  //     'exam_title': title,
  //     'description': description,
  //     'upload_date': Timestamp.fromDate(uploadDate),
  //     'liked_by': 0
  //   });
  //   await FirebaseDatabase.instance.ref('fastSearch').child('pyq${uploadDate.millisecondsSinceEpoch}').update({
  //     'id': snapshot.id,
  //     'text': title + description,
  //     'type': 'pyq'  
  //   });
  // }

  Future<void> addPart(String productId, String year, String overallDifficulty) async {
    await _firestore.collection('products').doc(productId).collection('parts').add({
      'part_name': year,
      'part_subtitle': overallDifficulty
    });
  }

  Future<void> addDocument(String productId, String partId, String title, String subject, String subtitle, int totalLength,String url) async {
    await _firestore.collection('products').doc(productId).collection('parts').doc(partId).collection('documents').add({
      'document_title': title,
      'subject': subject,
      'subtitle': subtitle,
      'total_length': totalLength,
      'pdf_url': url // Add the URL if needed
    });
  }
}
