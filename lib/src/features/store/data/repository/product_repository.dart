import '../model/product_model.dart';
import '../sourse/product_datasource.dart';

class ProductRepository {
  final ProductDataSource dataSource;

  ProductRepository(this.dataSource);

  Future<List<Product>> getProducts() async {
    return await dataSource.fetchProducts();
  }
}
