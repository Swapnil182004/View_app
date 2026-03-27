import 'package:flutter/material.dart';

class ChatNotify extends StatelessWidget {
  const ChatNotify({
    Key? key,
    required this.number,
    this.boxSize = 30,
    this.color = Colors.red,
  }) : super(key: key);

  final int number;
  final double boxSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: number > 0,
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints(
          minWidth: boxSize,
          minHeight: boxSize,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          number > 99 ? "99+" : "$number",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
