import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_converter/model/chat_model.dart';
import 'package:currency_converter/model/contact_form_model.dart';
import 'package:currency_converter/model/ticket_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerCareService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections - will be created automatically
  static const String _ticketsCollection = 'support_tickets';
  static const String _chatsCollection = 'live_chats';
  static const String _contactFormsCollection = 'contact_forms';
  static const String _settingsCollection = 'customer_care_settings';

  // Initialize collections with default data
  static Future<void> initializeCollections() async {
    try {
      print('🔄 Initializing Customer Care Collections...');
      
      // Create settings document if it doesn't exist
      final settingsDoc = await _firestore
          .collection(_settingsCollection)
          .doc('config')
          .get();
      
      if (!settingsDoc.exists) {
        await _firestore
            .collection(_settingsCollection)
            .doc('config')
            .set({
          'initialized': true,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'version': '1.0.0',
          'features': {
            'tickets': true,
            'liveChat': true,
            'contactForms': true,
          },
          'autoResponses': {
            'welcome': 'Hello! Welcome to Currency Converter Support. How can I help you today?',
            'offline': 'We are currently offline. Please leave a message and we\'ll get back to you soon.',
            'closing': 'Thank you for contacting us. Is there anything else I can help you with?',
          }
        });
        print('✅ Customer Care settings initialized');
      }

      // Create sample data for testing (only in debug mode)
      await _createSampleDataIfNeeded();
      
      print('✅ Customer Care Collections initialized successfully');
    } catch (e) {
      print('❌ Error initializing Customer Care Collections: $e');
    }
  }

  static Future<void> _createSampleDataIfNeeded() async {
    try {
      // Check if we already have data
      final ticketsSnapshot = await _firestore
          .collection(_ticketsCollection)
          .limit(1)
          .get();
      
      if (ticketsSnapshot.docs.isEmpty) {
        // Create sample ticket for testing
        await _firestore.collection(_ticketsCollection).add({
          'title': 'Welcome to Customer Care',
          'description': 'This is a sample ticket to test the system.',
          'userEmail': 'admin@currencyconverter.com',
          'userName': 'System Admin',
          'status': 'closed',
          'priority': 'low',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'tags': ['system', 'sample'],
        });
        print('✅ Sample ticket created');
      }
    } catch (e) {
      print('⚠️ Could not create sample data: $e');
    }
  }

  // Support Tickets
  static Future<String> createSupportTicket({
    required String title,
    required String description,
    String priority = 'medium',
    List<String>? tags,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final ticket = SupportTicket(
        id: '',
        title: title,
        description: description,
        userEmail: user.email ?? '',
        userName: user.displayName ?? 'Anonymous User',
        status: 'open',
        priority: priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags,
      );

      final docRef = await _firestore
          .collection(_ticketsCollection)
          .add(ticket.toMap());

      print('✅ Support ticket created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating support ticket: $e');
      throw Exception('Failed to create support ticket: $e');
    }
  }

  static Future<List<SupportTicket>> getUserTickets() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final querySnapshot = await _firestore
          .collection(_ticketsCollection)
          .where('userEmail', isEqualTo: user.email)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SupportTicket.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error getting user tickets: $e');
      throw Exception('Failed to get user tickets: $e');
    }
  }

  static Future<List<SupportTicket>> getAllTickets() async {
    try {
      final querySnapshot = await _firestore
          .collection(_ticketsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SupportTicket.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error getting all tickets: $e');
      throw Exception('Failed to get all tickets: $e');
    }
  }

  static Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      await _firestore
          .collection(_ticketsCollection)
          .doc(ticketId)
          .update({
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Ticket status updated: $ticketId -> $status');
    } catch (e) {
      print('❌ Error updating ticket status: $e');
      throw Exception('Failed to update ticket status: $e');
    }
  }

  static Stream<List<SupportTicket>> getTicketsStream() {
    return _firestore
        .collection(_ticketsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportTicket.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Live Chat
  static Future<String> startLiveChat() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user already has an active chat
      final existingChatQuery = await _firestore
          .collection(_chatsCollection)
          .where('userEmail', isEqualTo: user.email)
          .where('status', whereIn: ['active', 'waiting'])
          .limit(1)
          .get();

      if (existingChatQuery.docs.isNotEmpty) {
        return existingChatQuery.docs.first.id;
      }

      final chat = LiveChat(
        id: '',
        userEmail: user.email ?? '',
        userName: user.displayName ?? 'Anonymous User',
        status: 'active',
        messages: [
          ChatMessage(
            text: 'Hello! Welcome to Currency Converter Support. How can I help you today?',
            isUser: false,
            timestamp: DateTime.now(),
            senderName: 'Support Agent',
          ),
        ],
        startTime: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_chatsCollection)
          .add(chat.toMap());

      print('✅ Live chat started: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error starting live chat: $e');
      throw Exception('Failed to start live chat: $e');
    }
  }

  static Future<void> sendChatMessage({
    required String chatId,
    required String message,
    required bool isUser,
    String? senderName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final chatMessage = ChatMessage(
        text: message,
        isUser: isUser,
        timestamp: DateTime.now(),
        senderName: senderName ?? (isUser ? (user.displayName ?? 'You') : 'Support Agent'),
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .update({
        'messages': FieldValue.arrayUnion([chatMessage.toMap()]),
      });

      print('✅ Chat message sent: $chatId');
    } catch (e) {
      print('❌ Error sending chat message: $e');
      throw Exception('Failed to send chat message: $e');
    }
  }

  // Admin reply to chat
  static Future<void> sendAdminReply({
    required String chatId,
    required String message,
    required String adminName,
  }) async {
    try {
      final chatMessage = ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
        senderName: adminName,
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .update({
        'messages': FieldValue.arrayUnion([chatMessage.toMap()]),
        'assignedAgent': adminName,
      });

      print('✅ Admin reply sent: $chatId');
    } catch (e) {
      print('❌ Error sending admin reply: $e');
      throw Exception('Failed to send admin reply: $e');
    }
  }

  static Stream<LiveChat?> getChatStream(String chatId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return LiveChat.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  static Future<List<LiveChat>> getAllChats() async {
    try {
      final querySnapshot = await _firestore
          .collection(_chatsCollection)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LiveChat.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error getting all chats: $e');
      throw Exception('Failed to get all chats: $e');
    }
  }

  static Future<void> endChat(String chatId) async {
    try {
      await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .update({
        'status': 'closed',
        'endTime': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Chat ended: $chatId');
    } catch (e) {
      print('❌ Error ending chat: $e');
      throw Exception('Failed to end chat: $e');
    }
  }

  // Contact Forms
  static Future<String> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final contactForm = ContactForm(
        id: '',
        name: name,
        email: email,
        subject: subject,
        message: message,
        status: 'new',
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_contactFormsCollection)
          .add(contactForm.toMap());

      print('✅ Contact form submitted: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error submitting contact form: $e');
      throw Exception('Failed to submit contact form: $e');
    }
  }

  static Future<List<ContactForm>> getAllContactForms() async {
    try {
      final querySnapshot = await _firestore
          .collection(_contactFormsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ContactForm.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error getting contact forms: $e');
      throw Exception('Failed to get contact forms: $e');
    }
  }

  static Future<void> updateContactFormStatus(String formId, String status) async {
    try {
      await _firestore
          .collection(_contactFormsCollection)
          .doc(formId)
          .update({
        'status': status,
        'respondedAt': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Contact form status updated: $formId -> $status');
    } catch (e) {
      print('❌ Error updating contact form status: $e');
      throw Exception('Failed to update contact form status: $e');
    }
  }

  static Stream<List<ContactForm>> getContactFormsStream() {
    return _firestore
        .collection(_contactFormsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContactForm.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Statistics
  static Future<Map<String, int>> getStatistics() async {
    try {
      final ticketsSnapshot = await _firestore.collection(_ticketsCollection).get();
      final chatsSnapshot = await _firestore.collection(_chatsCollection).get();
      final formsSnapshot = await _firestore.collection(_contactFormsCollection).get();

      final openTickets = ticketsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'open')
          .length;

      final activeChats = chatsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'active')
          .length;

      final newForms = formsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'new')
          .length;

      return {
        'totalTickets': ticketsSnapshot.docs.length,
        'openTickets': openTickets,
        'totalChats': chatsSnapshot.docs.length,
        'activeChats': activeChats,
        'totalForms': formsSnapshot.docs.length,
        'newForms': newForms,
      };
    } catch (e) {
      print('❌ Error getting statistics: $e');
      throw Exception('Failed to get statistics: $e');
    }
  }

  // Auto-response for chat
  static String getAutomatedResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('rate') || message.contains('alert')) {
      return "For rate alerts, go to the Rate Alerts section and tap the + button. You can set target rates and choose when to be notified. Would you like me to guide you through the process?";
    } else if (message.contains('notification') || message.contains('notify')) {
      return "To manage notifications, go to Settings > Notification Settings. You can customize alert types, frequency, and quiet hours. Is there a specific notification issue you're experiencing?";
    } else if (message.contains('currency') || message.contains('exchange')) {
      return "We support over 170+ currencies with real-time rates updated every 60 seconds. You can add currencies to your watchlist for quick access. Which currencies are you interested in?";
    } else if (message.contains('bug') || message.contains('error') || message.contains('problem')) {
      return "I'm sorry to hear you're experiencing issues. Can you please describe the problem in detail? Include what you were doing when it occurred and any error messages you saw.";
    } else if (message.contains('account') || message.contains('login') || message.contains('password')) {
      return "For account-related issues, I can help you with password resets, profile updates, or account deletion. What specific account issue are you facing?";
    } else if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return "Hello! I'm here to help you with any questions about the Currency Converter app. What can I assist you with today?";
    } else if (message.contains('thank') || message.contains('thanks')) {
      return "You're welcome! Is there anything else I can help you with regarding the Currency Converter app?";
    } else {
      return "Thank you for your message. For complex issues, I recommend using our contact form or emailing us directly. Our team will get back to you within 24 hours. Is there anything else I can help you with right now?";
    }
  }
}
