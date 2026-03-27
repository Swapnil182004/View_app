// lib/services/news_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_course/src/features/course/data/models/news_model.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'news';

  // Get all active news as a Stream (real-time updates)
  // Note: Using simpler query to avoid composite index requirement
  // Sorting is done in memory after fetching
  Stream<List<NewsModel>> getNewsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final newsList = snapshot.docs
              .map((doc) => NewsModel.fromFirestore(doc))
              .toList();
          // Sort by priority (ascending), then by date (descending)
          newsList.sort((a, b) {
            final priorityCompare = a.priority.compareTo(b.priority);
            if (priorityCompare != 0) return priorityCompare;
            return b.date.compareTo(a.date);
          });
          return newsList;
        });
  }

  // Get all active news as Future (one-time fetch)
  // Note: Using simpler query to avoid composite index requirement
  Future<List<NewsModel>> getNews() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final newsList = snapshot.docs
          .map((doc) => NewsModel.fromFirestore(doc))
          .toList();
      
      // Sort by priority (ascending), then by date (descending)
      newsList.sort((a, b) {
        final priorityCompare = a.priority.compareTo(b.priority);
        if (priorityCompare != 0) return priorityCompare;
        return b.date.compareTo(a.date);
      });
      
      return newsList;
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }

  // Get news by category
  Future<List<NewsModel>> getNewsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NewsModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching news by category: $e');
      return [];
    }
  }

  // Get single news item by ID
  Future<NewsModel?> getNewsById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();

      if (doc.exists) {
        return NewsModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching news by ID: $e');
      return null;
    }
  }

  // Add news (for admin app)
  Future<bool> addNews(NewsModel news) async {
    try {
      await _firestore.collection(_collection).add(news.toFirestore());
      return true;
    } catch (e) {
      print('Error adding news: $e');
      return false;
    }
  }

  // Update news (for admin app)
  Future<bool> updateNews(String id, NewsModel news) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(news.toFirestore());
      return true;
    } catch (e) {
      print('Error updating news: $e');
      return false;
    }
  }

  // Delete news (soft delete - set isActive to false)
  Future<bool> deleteNews(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'isActive': false});
      return true;
    } catch (e) {
      print('Error deleting news: $e');
      return false;
    }
  }
}
