// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import 'package:no_screenshot/no_screenshot.dart';
// import 'package:online_course/src/features/course/data/models/comment_model.dart';
//
// class VideoPlayer extends StatefulWidget {
//   final String url;
//   const VideoPlayer({Key? key, required this.url}) : super(key: key);
//   @override
//   State<VideoPlayer> createState() => VideoPlayerState();
// }
//
// class VideoPlayerState extends State<VideoPlayer> {
//   // Create a [Player] to control playback.
//   late final player = Player();
//   // Create a [VideoController] to handle video output from [Player].
//   late final controller = VideoController(player);
//
//   final TextEditingController _textController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final _noScreenshot = NoScreenshot.instance;
//
//
//   List<Comment> comments = [];
//   late StreamSubscription<QuerySnapshot> _subscription;
//   final User _user = FirebaseAuth.instance.currentUser!;
//
//   @override
//   void initState() {
//     super.initState();
//     // Play a [Media] or [Playlist].
//     _subscribeToComments();
//     _preventScreenShot();
//     player.open(Media(widget.url));
//   }
//
//   @override
//   void dispose() {
//     player.dispose();
//      _subscription.cancel(); // Cancel subscription to avoid memory leaks
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [SizedBox(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.width * 9.0 / 16.0,
//             // Use [Video] widget to display video output.
//             child: GestureDetector(
//               onSecondaryTap: null,
//               child: Video(controller: controller)),
//           )
//           ,
//              Expanded(
//           child: ListView.builder(
//             itemCount: comments.length,
//             controller: _scrollController,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: NetworkImage(comments[index].imageUrl),
//                 ),
//                 title: Text(comments[index].text),
//                 subtitle: Text(comments[index].name),
//               );
//             },
//           ),
//         ),
//          Container(
//
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _textController,
//                   decoration: const InputDecoration(hintText: 'Add a comment'),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.send),
//                 onPressed: () {
//                   if (_textController.text.isNotEmpty) {
//                     _sendComment(Comment(text: _textController.text, name: _user.displayName ?? 'Anonymous', imageUrl: _user.photoURL ?? '', timestamp: Timestamp.now(), videoUrl: widget.url));
//                     setState(() {
//
//                       _textController.clear();
//                     });
//                    WidgetsBinding.instance.addPostFrameCallback((_) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });
//                   }
//                 },
//               ),
//            ],
//           ),
//         ),
//
//
//
//
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _preventScreenShot() async{
//     final result = await _noScreenshot.screenshotOff();
//     print(result);
//   }
//
//
//
//    Future<void> _sendComment(Comment comment) async {
//     if (_textController.text.isNotEmpty) {
//       await FirebaseFirestore.instance.collection('comments').add(comment.toJson());
//       setState(() {
//         _textController.clear();
//       });
//     }
//   }
// // Method to subscribe to comments from Firestore in real-time
//   void _subscribeToComments() {
//     _subscription = FirebaseFirestore.instance
//         .collection('comments')
//         .where('videoUrl', isEqualTo: widget.url)
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .listen((snapshot) {
//       setState(() {
//         comments = snapshot.docs.map((doc) => Comment(
//           text: doc['text'],
//           name: doc['name'],
//           imageUrl: doc['imageUrl'],
//           timestamp: doc['timestamp'],
//         )).toList();
//       });
//     });
//   }
//
//
//
//    void _fetchComments() async {
//     final snapshot = await FirebaseFirestore.instance.collection('comments').where('videoUrl', isEqualTo: widget.url).orderBy( 'timestamp', descending: true).get();
//     setState(() {
//       comments = snapshot.docs.map((doc) => Comment(text: doc['text'], name: doc['name'], imageUrl: doc['imageUrl'], timestamp: doc['timestamp'])).toList();
//     });
//   }
//
//
// }
