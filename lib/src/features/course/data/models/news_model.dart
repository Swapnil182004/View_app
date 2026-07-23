import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final DateTime date;
  final String? imageUrl;
  final String category;
  final bool isActive;
  final DateTime createdAt;
  final int priority;
  final String? newsLink; // External news URL
  final String? pdfUrl;   // Optional PDF URL from Firebase Storage

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    this.content = '',
    required this.date,
    this.imageUrl,
    this.category = 'General',
    this.isActive = true,
    required this.createdAt,
    this.priority = 999,
    this.newsLink,
    this.pdfUrl,
  });

  // Factory constructor to create NewsModel from Firestore document
  factory NewsModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Safely parse date - use createdAt as fallback if date doesn't exist
    DateTime parsedDate;
    if (data['date'] != null && data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }
    
    // Safely parse createdAt
    DateTime parsedCreatedAt;
    if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      parsedCreatedAt = DateTime.now();
    }
    
    return NewsModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      date: parsedDate,
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'General',
      isActive: data['isActive'] ?? true,
      createdAt: parsedCreatedAt,
      priority: data['priority'] ?? 999,
      newsLink: data['newsLink'],
      pdfUrl: data['pdfUrl'],
    );
  }

  // Convert NewsModel to Map for Firestore upload
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'category': category,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority,
      'newsLink': newsLink,
      'pdfUrl': pdfUrl,
    };
  }

  /// Check if this news has a downloadable PDF
  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;

  /// Check if description is non-empty (for conditional UI)
  bool get hasDescription => description.isNotEmpty && description != '""';

  /// Check if this has a newsLink (external article URL)
  bool get hasNewsLink => newsLink != null && newsLink!.isNotEmpty;

  // Helper method to format date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Category badge color helper
  CategoryInfo get categoryInfo {
    switch (category.toLowerCase()) {
      case 'academic':
        return CategoryInfo('Academic', const Color(0xFF1A56DB));
      case 'event':
        return CategoryInfo('Event', const Color(0xFF1D4ED8));
      case 'notice':
        return CategoryInfo('Notice', const Color(0xFFE67E22));
      default:
        return CategoryInfo('General', const Color(0xFF757575));
    }
  }
}

class CategoryInfo {
  final String label;
  final Color color;

  CategoryInfo(this.label, this.color);
}