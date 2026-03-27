import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product_model.dart';

class ProductDataSource {
  final FirebaseFirestore _firestore;

  ProductDataSource(this._firestore);

  Future<List<Product>> fetchProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) {
      return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
