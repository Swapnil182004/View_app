class Section {
  final String title;
  final String price;

  Section({
    required this.title,
    required this.price,
  });

  /// sectionId is NOT stored in course_sections collection.
  /// It's derived as: courseId + title.toLowerCase()
  /// e.g. courseId=14661, title="Basic Programming" → "14661basic programming"
  String deriveSectionId(int courseId) {
    return '${courseId}${title.toLowerCase()}';
  }

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      title: json['title'] as String? ?? '',
      price: json['price'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'price': price,
  };
}
