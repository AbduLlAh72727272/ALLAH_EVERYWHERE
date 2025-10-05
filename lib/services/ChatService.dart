import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create a new chat session
  Future<String> createChatSession({
    required String alimId,
    required String question,
    required String category,
  }) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      final chatDoc = await _firestore.collection('chats').add({
        'participants': [currentUserId, alimId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': question,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {currentUserId: 0, alimId: 1},
        'category': category,
        'status': 'active', // active, closed, pending
        'userId': currentUserId,
        'alimId': alimId,
      });

      // Send initial message
      await sendMessage(
        chatId: chatDoc.id,
        message: question,
        messageType: 'text',
      );

      return chatDoc.id;
    } catch (e) {
      throw Exception('Failed to create chat session: $e');
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String messageType, // text, image, audio, file
    String? mediaUrl,
  }) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      final messageData = {
        'senderId': currentUserId,
        'message': message,
        'messageType': messageType,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'mediaUrl': mediaUrl,
      };

      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // Update chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount.$currentUserId': 0,
      });

      // Increment unread count for the other participant
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final otherParticipant = participants.firstWhere((id) => id != currentUserId);
      
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$otherParticipant': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get user's chats
  Stream<QuerySnapshot> getUserChatsStream() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Get available alims/scholars
  Future<List<Map<String, dynamic>>> getAvailableAlims() async {
    try {
      final querySnapshot = await _firestore
          .collection('alims')
          .where('isAvailable', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Scholar',
          'title': data['title'] ?? 'Islamic Scholar',
          'specialization': data['specialization'] ?? ['General'],
          'education': data['education'] ?? '',
          'experience': data['experience'] ?? 0,
          'rating': data['rating'] ?? 0.0,
          'totalReviews': data['totalReviews'] ?? 0,
          'profilePicture': data['profilePicture'] ?? '',
          'languages': data['languages'] ?? ['English'],
          'responseTime': data['responseTime'] ?? 'Within 24 hours',
          'isOnline': data['isOnline'] ?? false,
          'isVerified': data['isVerified'] ?? false,
          'bio': data['bio'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching alims: $e');
      // Return fallback data
      return _getFallbackAlims();
    }
  }

  List<Map<String, dynamic>> _getFallbackAlims() {
    return [
      {
        'id': 'alim_1',
        'name': 'Sheikh Muhammad Ahmad',
        'title': 'Senior Islamic Scholar',
        'specialization': ['Quran', 'Hadith', 'Fiqh'],
        'education': 'PhD in Islamic Studies, Al-Azhar University',
        'experience': 15,
        'rating': 4.9,
        'totalReviews': 156,
        'profilePicture': '',
        'languages': ['English', 'Arabic', 'Urdu'],
        'responseTime': 'Within 2 hours',
        'isOnline': true,
        'isVerified': true,
        'bio': 'Specialized in Quranic interpretation and Islamic jurisprudence with 15+ years of teaching experience.',
      },
      {
        'id': 'alim_2',
        'name': 'Dr. Fatima Al-Zahra',
        'title': 'Islamic Scholar & Educator',
        'specialization': ['Women\'s Issues', 'Family', 'Islamic Ethics'],
        'education': 'Masters in Islamic Studies, Medina University',
        'experience': 12,
        'rating': 4.8,
        'totalReviews': 89,
        'profilePicture': '',
        'languages': ['English', 'Arabic'],
        'responseTime': 'Within 4 hours',
        'isOnline': false,
        'isVerified': true,
        'bio': 'Expert in women\'s issues in Islam and family guidance with extensive counseling experience.',
      },
      {
        'id': 'alim_3',
        'name': 'Imam Abdullah Hassan',
        'title': 'Imam & Islamic Counselor',
        'specialization': ['Prayer', 'Zakat', 'Marriage', 'General'],
        'education': 'Graduate of Islamic University of Medina',
        'experience': 20,
        'rating': 4.7,
        'totalReviews': 203,
        'profilePicture': '',
        'languages': ['English', 'Arabic', 'French'],
        'responseTime': 'Within 6 hours',
        'isOnline': true,
        'isVerified': true,
        'bio': 'Community imam with 20 years of experience in Islamic guidance and counseling.',
      },
      {
        'id': 'alim_4',
        'name': 'Sheikh Omar Ibn Yusuf',
        'title': 'Quran Recitation Expert',
        'specialization': ['Quran', 'Tajweed', 'Memorization'],
        'education': 'Certified Qari from Darul Uloom',
        'experience': 10,
        'rating': 4.6,
        'totalReviews': 67,
        'profilePicture': '',
        'languages': ['English', 'Arabic', 'Urdu'],
        'responseTime': 'Within 12 hours',
        'isOnline': false,
        'isVerified': true,
        'bio': 'Expert in Quran recitation and memorization techniques with beautiful voice.',
      },
    ];
  }

  // Upload media file
  Future<String> uploadMedia({
    required File file,
    required String chatId,
    required String messageType,
  }) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      final fileName = '${DateTime.now().millisecondsSinceEpoch}';
      final ref = _storage
          .ref()
          .child('chat_media')
          .child(chatId)
          .child('$fileName.${file.path.split('.').last}');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return;

      // Update unread count
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$currentUserId': 0,
      });

      // Mark individual messages as read
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Close chat session
  Future<void> closeChatSession(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'status': 'closed',
        'closedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to close chat session: $e');
    }
  }

  // Rate alim
  Future<void> rateAlim({
    required String chatId,
    required String alimId,
    required double rating,
    String? review,
  }) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Add review
      await _firestore.collection('reviews').add({
        'userId': currentUserId,
        'alimId': alimId,
        'chatId': chatId,
        'rating': rating,
        'review': review ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update alim's average rating
      final alimDoc = await _firestore.collection('alims').doc(alimId).get();
      final currentRating = alimDoc.data()?['rating'] ?? 0.0;
      final totalReviews = alimDoc.data()?['totalReviews'] ?? 0;
      
      final newTotalReviews = totalReviews + 1;
      final newRating = ((currentRating * totalReviews) + rating) / newTotalReviews;

      await _firestore.collection('alims').doc(alimId).update({
        'rating': newRating,
        'totalReviews': newTotalReviews,
      });
    } catch (e) {
      throw Exception('Failed to rate alim: $e');
    }
  }

  // Get chat categories
  List<Map<String, dynamic>> getChatCategories() {
    return [
      {
        'id': 'general',
        'name': 'General Questions',
        'icon': Icons.help_outline,
        'description': 'General Islamic questions and guidance',
      },
      {
        'id': 'prayer',
        'name': 'Prayer & Worship',
        'icon': Icons.mosque,
        'description': 'Questions about prayer, fasting, and worship',
      },
      {
        'id': 'family',
        'name': 'Family & Marriage',
        'icon': Icons.family_restroom,
        'description': 'Family matters, marriage, and relationships',
      },
      {
        'id': 'business',
        'name': 'Business & Finance',
        'icon': Icons.business,
        'description': 'Islamic finance, business ethics, and transactions',
      },
      {
        'id': 'personal',
        'name': 'Personal Development',
        'icon': Icons.self_improvement,
        'description': 'Spiritual growth and personal development',
      },
      {
        'id': 'education',
        'name': 'Islamic Education',
        'icon': Icons.school,
        'description': 'Learning and teaching Islamic knowledge',
      },
    ];
  }

  // Search message history
  Future<List<Map<String, dynamic>>> searchMessages({
    required String chatId,
    required String query,
  }) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('message', isGreaterThanOrEqualTo: query)
          .where('message', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return messages.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'message': data['message'],
          'senderId': data['senderId'],
          'timestamp': data['timestamp'],
          'messageType': data['messageType'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }
}