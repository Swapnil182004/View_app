class CourseLessons {
  final String name;
  final String image;
  final String duration;
  final String videoUrl;
  final int type;
  final String sectionId;

  CourseLessons({
    required this.name,
    required this.image,
    required this.duration,
    required this.videoUrl,
    this.type = 1,
    this.sectionId =""
  });

  factory CourseLessons.fromJson(Map<String, dynamic> json) {
    return CourseLessons(
      name: json['name'],
      image: json['image'],
      duration: json['duration'],
      videoUrl: json['video_url'],
      type: json['type'] as int,
      sectionId: json['sectionId']
    );
  }
}
