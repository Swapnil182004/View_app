class Product {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category; // ✅ ADDED THIS

  Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category, // ✅ ADDED THIS
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      imageUrl: map['image_url'] ?? '',
      category: map['category'] ?? 'All', // ✅ ADDED THIS (defaults to 'All' if missing in DB)
    );
  }
}
