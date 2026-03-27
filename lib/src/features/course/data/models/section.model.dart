class Section{
  final String title;
  final String price;
  Section({
    required this.title,
    required this.price
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      title: json['title'] as String,
      price: json['price'] as String
    );
  }
}
