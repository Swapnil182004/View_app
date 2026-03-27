import 'package:flutter/material.dart';
import 'package:online_course/src/widgets/custom_image.dart';
import 'chat_notify.dart';

class ChatItem extends StatelessWidget {
  const ChatItem(
    this.chatData, {
    Key? key,
    this.onTap,
    this.isNotified = true,
    this.profileSize = 50,
  }) : super(key: key);

  final Map chatData;
  final bool isNotified;
  final GestureTapCallback? onTap;
  final double profileSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPhoto(colorScheme),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  buildNameAndTime(colorScheme),
                  const SizedBox(height: 8),
                  _buildTextAndNotified(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAndNotified(ColorScheme colorScheme) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            chatData['last_text'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
        if (isNotified)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChatNotify(
              number: chatData['notify'],
              boxSize: 22,
              color: colorScheme.tertiary, // VIEW Pink for notifications
            ),
          )
      ],
    );
  }

  Widget _buildPhoto(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomImage(
          chatData['image'],
          width: profileSize,
          height: profileSize,
        ),
      ),
    );
  }

  Widget buildNameAndTime(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            chatData['name'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            chatData['date'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }
}
