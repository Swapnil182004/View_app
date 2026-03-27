import 'package:cloud_firestore/cloud_firestore.dart';

class NotesModel {
  final String title;
  final String subtitle;
  final String url;
 final int type;
 final Timestamp timestamp;
  NotesModel({required this.title, required this.subtitle, required this.url, this.type = 0,required this.timestamp});
}
