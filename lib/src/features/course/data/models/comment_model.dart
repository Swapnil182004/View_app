import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String text;
  final String name;
  final String imageUrl;
  final String videoUrl;
  final Timestamp timestamp;

  Comment({required this.text, required this.name, required this.imageUrl,required this.timestamp,  this.videoUrl = ''});

  Map<String, dynamic> toJson() => {
    'text': text,
    'name': name,
    'imageUrl': imageUrl,
    'timestamp': timestamp,
    'videoUrl': videoUrl
  };

}
