import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:online_course/core/utils/app_navigate.dart';
import 'package:online_course/src/features/course/data/models/course_lessons.dart';
import 'package:online_course/src/features/document_viewer/presentation/pdf_viewer.dart';
import 'package:online_course/src/features/video/presentation/screen/yotutube_player.dart';
import 'package:online_course/src/widgets/custom_image.dart';

class LessonItem extends StatelessWidget {
  const LessonItem({
    Key? key,
    required this.data,
    this.clickable = false,
    required this.type,
    this.isPurchased = false,
  }) : super(key: key);
  
  final CourseLessons data;
  final bool clickable;
  final int type;
  final bool isPurchased;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!clickable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Please purchase or renew the course first"),
              backgroundColor: const Color(0xFFE67E22),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          return;
        }
        if (type == 2) {
          if (data.videoUrl.contains('youtu.be') ||
              data.videoUrl.contains('youtube')) {
            AppNavigator.to(
              context,
              YotutubePlayer(url: data.videoUrl),
            );
          } else {
            final user = FirebaseAuth.instance.currentUser;
            var jitsiMeet = JitsiMeet();
            var options = JitsiMeetConferenceOptions(
              room: data.videoUrl,
              configOverrides: {
                "startWithAudioMuted": true,
                "startWithVideoMuted": true,
                "subject": "Examplan-b live class",
              },
              featureFlags: {
                "unsaferoomwarning.enabled": false,
                "add-people.enabled": false,
                "recording.enabled": false,
                "breakout-rooms.enabled": false,
                "invite.enabled": false,
                "android.screensharing.enabled": false,
                "kick-out.enabled": false,
                "lobby-mode.enabled": false,
                "meeting-name.enabled": false,
                "participants.enabled": false,
                "security-options.enabled": false,
                "welcomepage.enabled": false,
              },
              userInfo: JitsiMeetUserInfo(
                displayName: user?.displayName ?? "Anonymous",
                email: user?.email ?? "no@email",
              ),
            );
            jitsiMeet.join(options);
          }
        } else {
          AppNavigator.to(
            context,
            PdfViewer(url: data.videoUrl ?? ''),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: clickable
                ? const Color(0xFFE8ECF9)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail with Lock Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: clickable
                    ? const Color(0xFFE8ECF9)
                    : const Color(0xFFF5F5F5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomImage(
                      data.image ?? '',
                      radius: 10,
                      height: 75,
                      width: 75,
                    ),
                  ),
                  // Lock Overlay
                  if (!clickable)
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  // Play Icon for Clickable Videos
                  if (clickable && type == 2)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A56DB).withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Lesson Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Meta Info Row - FIXED OVERFLOW
                  Row(
                    children: [
                      // Duration - Made flexible
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: Color(0xFF2563EB),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  data.duration,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8ECF9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type == 2 ? Icons.play_circle_outline : Icons.article_outlined,
                              color: const Color(0xFF1A56DB),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type == 2 ? "Video" : "Exercise",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: clickable
                  ? const Color(0xFF1A56DB)
                  : const Color(0xFFBDBDBD),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  bool CheckIfExpired(Timestamp purchaseDate) {
    DateTime timestampDate = purchaseDate.toDate();
    DateTime currentDate = DateTime.now();
    int differenceInDays = currentDate.difference(timestampDate).inDays;
    
    if (differenceInDays >= 30) {
      return true;
    } else {
      return false;
    }
  }
}
