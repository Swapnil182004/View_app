import 'package:flutter/material.dart';



class ChatSearchBlock extends StatefulWidget {
  final Function(String) onSearch;

  const ChatSearchBlock({super.key, required this.onSearch});

  @override
  State<ChatSearchBlock> createState() => _ChatSearchBlockState();
}

class _ChatSearchBlockState extends State<ChatSearchBlock> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        height: 48, // Fixed height to reduce size
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? Colors.white
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 15, // Slightly smaller font
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: "Search question sets",
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            // Leading search icon in emerald
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.search,
                color: theme.colorScheme.primary, // Emerald green
                size: 22,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 48,
            ),
            // Trailing clear button
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                      widget.onSearch('');
                    },
                    tooltip: 'Clear search',
                    padding: const EdgeInsets.all(8),
                  )
                : null,
            // Remove all default borders and padding
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            // Remove default filled background
            filled: false,
          ),
          onSubmitted: (value) {
            widget.onSearch(_searchController.text.trim());
          },
          onChanged: (value) {
            setState(() {}); // Rebuild to show/hide clear button
          },
        ),
      ),
    );
  }
}

