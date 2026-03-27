import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:online_course/src/features/course/data/models/comment_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'share_video.dart';

class YotutubePlayer extends StatefulWidget {
  final String url;
  const YotutubePlayer({super.key, required this.url});

  @override
  State<YotutubePlayer> createState() => _YotutubePlayerState();
}

class _YotutubePlayerState extends State<YotutubePlayer> {
  late YoutubePlayerController _controller;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _noScreenshot = NoScreenshot.instance;

  List<Comment> comments = [];
  late StreamSubscription<QuerySnapshot> _subscription;
  final User? _user = null;
  // FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url) ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        hideThumbnail: true,
        disableDragSeek: false,
      ),
    );
    _subscribeToComments();
    _preventScreenShot();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        showVideoProgressIndicator: true,
        controller: _controller,
      ),
      builder: (context, player) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                player,
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRScannerScreen(
                              videoId: widget.url,
                            ),
                          ),
                        );
                      },
                      child: const Text("Share on web"),
                    )),
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(comments[index].imageUrl),
                        ),
                        title: Text(comments[index].text),
                        subtitle: Text(comments[index].name),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration:
                              const InputDecoration(hintText: 'Add a comment'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            _sendComment(Comment(
                                text: _textController.text,
                                name: _user?.displayName ?? 'Anonymous',
                                imageUrl: _user?.photoURL ?? '',
                                timestamp: Timestamp.now(),
                                videoUrl: widget.url));
                            setState(() {
                              _textController.clear();
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _preventScreenShot() async {
    _noScreenshot.screenshotOff();
  }

  Future<void> _sendComment(Comment comment) async {
    if (_textController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('comments')
          .add(comment.toJson());
      setState(() {
        _textController.clear();
      });
    }
  }

// Method to subscribe to comments from Firestore in real-time
  void _subscribeToComments() {
    _subscription = FirebaseFirestore.instance
        .collection('comments')
        .where('videoUrl', isEqualTo: widget.url)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        comments = snapshot.docs
            .map((doc) => Comment(
                  text: doc['text'],
                  name: doc['name'],
                  imageUrl: doc['imageUrl'],
                  timestamp: doc['timestamp'],
                ))
            .toList();
      });
    });
  }

  void _fetchComments() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('comments')
        .where('videoUrl', isEqualTo: widget.url)
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      comments = snapshot.docs
          .map((doc) => Comment(
              text: doc['text'],
              name: doc['name'],
              imageUrl: doc['imageUrl'],
              timestamp: doc['timestamp']))
          .toList();
    });
  }
}
