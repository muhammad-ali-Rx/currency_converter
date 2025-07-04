import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_converter/model/Feedback.model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class FeedbackService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'user_feedback';

  // Submit feedback and auto-create collection
  static Future<bool> submitFeedback({
    required String type,
    required String name,
    required String email,
    required String message,
    String? steps,
    int? rating,
  }) async {
    try {
      print('🔄 Submitting feedback...');
      
      // Generate unique ID
      final String feedbackId = _firestore.collection(_collectionName).doc().id;
      
      // Determine category and priority automatically
      final String category = _determineCategory(type);
      final String priority = _determinePriority(type);
      
      // Create feedback model
      final feedback = FeedbackModel(
        id: feedbackId,
        type: type,
        name: name.isEmpty ? 'Anonymous User' : name,
        email: email.isEmpty ? 'No email provided' : email,
        message: message,
        timestamp: DateTime.now(),
        status: 'New',
        priority: priority,
        category: category,
        steps: steps?.isEmpty == true ? null : steps,
        rating: rating,
      );

      // Submit to Firestore
      await _firestore
          .collection(_collectionName)
          .doc(feedbackId)
          .set(feedback.toJson());

      print('✅ Feedback submitted successfully with ID: $feedbackId');
      
      // Create initial setup if needed
      await _createInitialSetupIfNeeded();
      
      return true;
    } catch (e) {
      print('❌ Error submitting feedback: $e');
      return false;
    }
  }

  // Get all feedback for admin
  static Future<List<FeedbackModel>> getAllFeedback() async {
    try {
      print('🔄 Getting all feedback...');
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true)
          .get();

      final feedbacks = querySnapshot.docs
          .map((doc) => FeedbackModel.fromJson(doc.data()))
          .toList();

      print('✅ Retrieved ${feedbacks.length} feedback items');
      return feedbacks;
    } catch (e) {
      print('❌ Error getting feedback: $e');
      return [];
    }
  }

  // Get feedback with filters
  static Future<List<FeedbackModel>> getFilteredFeedback({
    String? status,
    String? priority,
    String? category,
    String? type,
  }) async {
    try {
      print('🔄 Getting filtered feedback...');
      
      Query query = _firestore.collection(_collectionName);

      if (status != null && status != 'All') {
        query = query.where('status', isEqualTo: status);
      }
      if (priority != null && priority != 'All') {
        query = query.where('priority', isEqualTo: priority);
      }
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      if (type != null && type != 'All') {
        query = query.where('type', isEqualTo: type);
      }

      query = query.orderBy('timestamp', descending: true);

      final querySnapshot = await query.get();
      final feedbacks = querySnapshot.docs
          .map((doc) => FeedbackModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      print('✅ Retrieved ${feedbacks.length} filtered feedback items');
      return feedbacks;
    } catch (e) {
      print('❌ Error getting filtered feedback: $e');
      return [];
    }
  }

  // Update feedback status
  static Future<bool> updateFeedbackStatus(String feedbackId, String newStatus) async {
    try {
      print('🔄 Updating feedback status to: $newStatus');
      
      await _firestore
          .collection(_collectionName)
          .doc(feedbackId)
          .update({
        'status': newStatus,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Feedback status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating feedback status: $e');
      return false;
    }
  }

  // Delete feedback
  static Future<bool> deleteFeedback(String feedbackId) async {
    try {
      print('🔄 Deleting feedback: $feedbackId');
      
      await _firestore
          .collection(_collectionName)
          .doc(feedbackId)
          .delete();

      print('✅ Feedback deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting feedback: $e');
      return false;
    }
  }

  // Get feedback statistics
  static Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      print('🔄 Getting feedback statistics...');
      
      final querySnapshot = await _firestore.collection(_collectionName).get();
      final feedbacks = querySnapshot.docs
          .map((doc) => FeedbackModel.fromJson(doc.data()))
          .toList();

      final stats = {
        'total': feedbacks.length,
        'new': feedbacks.where((f) => f.status == 'New').length,
        'inProgress': feedbacks.where((f) => f.status == 'In Progress').length,
        'resolved': feedbacks.where((f) => f.status == 'Resolved').length,
        'closed': feedbacks.where((f) => f.status == 'Closed').length,
        'highPriority': feedbacks.where((f) => f.priority == 'High' || f.priority == 'Critical').length,
        'averageRating': _calculateAverageRating(feedbacks),
        'byType': _groupByField(feedbacks, 'type'),
        'byCategory': _groupByField(feedbacks, 'category'),
        'byPriority': _groupByField(feedbacks, 'priority'),
      };

      print('✅ Statistics calculated successfully');
      return stats;
    } catch (e) {
      print('❌ Error getting feedback stats: $e');
      return {};
    }
  }

  // Real-time feedback stream
  static Stream<List<FeedbackModel>> getFeedbackStream() {
    print('🔄 Starting feedback stream...');
    
    return _firestore
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📡 Received ${snapshot.docs.length} feedback items from stream');
          return snapshot.docs
              .map((doc) => FeedbackModel.fromJson(doc.data()))
              .toList();
        });
  }

  // Search feedback
  static Future<List<FeedbackModel>> searchFeedback(String searchTerm) async {
    try {
      print('🔍 Searching feedback for: $searchTerm');
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('message', isGreaterThanOrEqualTo: searchTerm)
          .where('message', isLessThan: searchTerm + 'z')
          .get();

      final feedbacks = querySnapshot.docs
          .map((doc) => FeedbackModel.fromJson(doc.data()))
          .toList();

      print('✅ Found ${feedbacks.length} matching feedback items');
      return feedbacks;
    } catch (e) {
      print('❌ Error searching feedback: $e');
      return [];
    }
  }

  // Private helper methods
  static Future<void> _createInitialSetupIfNeeded() async {
    try {
      // Check if categories collection exists
      final categoriesSnapshot = await _firestore
          .collection('feedback_categories')
          .limit(1)
          .get();

      if (categoriesSnapshot.docs.isEmpty) {
        print('🔄 Creating initial feedback categories...');
        
        final categories = [
          {
            'id': 'bug_report',
            'name': 'Bug Report',
            'description': 'Report bugs and technical issues',
            'icon': 'bug_report',
            'color': '#F44336',
            'isActive': true,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          },
          {
            'id': 'feature_request',
            'name': 'Feature Request',
            'description': 'Suggest new features',
            'icon': 'lightbulb',
            'color': '#FF9800',
            'isActive': true,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          },
          {
            'id': 'general_feedback',
            'name': 'General Feedback',
            'description': 'General comments and suggestions',
            'icon': 'feedback',
            'color': '#2196F3',
            'isActive': true,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          },
        ];

        final batch = _firestore.batch();
        for (final category in categories) {
          final docRef = _firestore
              .collection('feedback_categories')
              .doc(category['id'] as String);
          batch.set(docRef, category);
        }
        await batch.commit();

        print('✅ Initial feedback categories created');
      }
    } catch (e) {
      print('❌ Error creating initial setup: $e');
    }
  }

  static String _determineCategory(String type) {
    switch (type.toLowerCase()) {
      case 'bug report':
      case 'app crash':
      case 'login issue':
      case 'data sync':
      case 'performance':
      case 'ui problem':
        return 'issue';
      case 'app rating':
        return 'rating';
      default:
        return 'feedback';
    }
  }

  static String _determinePriority(String type) {
    switch (type.toLowerCase()) {
      case 'bug report':
      case 'app crash':
      case 'login issue':
        return 'High';
      case 'data sync':
      case 'performance':
      case 'ui problem':
        return 'Medium';
      default:
        return 'Low';
    }
  }

  static double _calculateAverageRating(List<FeedbackModel> feedbacks) {
    final ratingsOnly = feedbacks
        .where((f) => f.rating != null)
        .map((f) => f.rating!)
        .toList();

    if (ratingsOnly.isEmpty) return 0.0;

    final sum = ratingsOnly.reduce((a, b) => a + b);
    return sum / ratingsOnly.length;
  }

  static Map<String, int> _groupByField(List<FeedbackModel> feedbacks, String field) {
    final Map<String, int> grouped = {};

    for (final feedback in feedbacks) {
      String value;
      switch (field) {
        case 'type':
          value = feedback.type;
          break;
        case 'category':
          value = feedback.category;
          break;
        case 'priority':
          value = feedback.priority;
          break;
        default:
          value = 'Unknown';
      }

      grouped[value] = (grouped[value] ?? 0) + 1;
    }

    return grouped;
  }
}