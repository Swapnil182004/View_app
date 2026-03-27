import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Green background added
      color: Theme.of(context).colorScheme.primary, // Emerald green background
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with white color for contrast against green background
          Expanded(
            child: Text(
              "Previous Year Questions",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white, // ✅ Changed to white for contrast
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          // Action icons with white color
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.filter_list,
                  color: Colors.white, // ✅ Changed to white
                  size: 24,
                ),
                onPressed: () {
                  // Add filter functionality
                },
                tooltip: 'Filter',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white, // ✅ Changed to white
                  size: 24,
                ),
                onPressed: () {
                  // Add menu functionality
                },
                tooltip: 'More options',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
