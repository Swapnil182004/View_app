import 'package:flutter/widgets.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiMeetPlayer extends StatelessWidget {
  const JitsiMeetPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _joinmeeting() {
    var jitsiMeet = JitsiMeet();
    var options = JitsiMeetConferenceOptions(room: 'jitsiIsAwesome');
    jitsiMeet.join(options);
  }
}
