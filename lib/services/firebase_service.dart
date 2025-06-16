import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency_contact_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Emergency Contacts Methods
  static Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('emergency_contacts')
          .orderBy('isPrimary', descending: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => EmergencyContactModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  static Future<void> addEmergencyContact(EmergencyContactModel contact) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('emergency_contacts')
          .add(contact.toMap());
    } catch (e) {
      print('Error adding emergency contact: $e');
      rethrow;
    }
  }

  static Future<void> updateEmergencyContact(EmergencyContactModel contact) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('emergency_contacts')
          .doc(contact.id)
          .update(contact.toMap());
    } catch (e) {
      print('Error updating emergency contact: $e');
      rethrow;
    }
  }

  static Future<void> deleteEmergencyContact(String contactId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('emergency_contacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      print('Error deleting emergency contact: $e');
      rethrow;
    }
  }

  // Emergency Alert Methods
  static Future<void> triggerEmergencyAlert({
    required String type,
    required Map<String, dynamic> location,
    required String additionalInfo,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final alertData = {
        'userId': currentUserId,
        'type': type,
        'location': location,
        'additionalInfo': additionalInfo,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'resolved': false,
      };

      // Add to emergency alerts collection
      await _firestore.collection('emergency_alerts').add(alertData);

      // Also add to user's emergency history
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('emergency_history')
          .add(alertData);

      // Notify emergency contacts (you can implement push notifications here)
      await _notifyEmergencyContacts(type, location, additionalInfo);
    } catch (e) {
      print('Error triggering emergency alert: $e');
      rethrow;
    }
  }

  static Future<void> _notifyEmergencyContacts(
      String type,
      Map<String, dynamic> location,
      String additionalInfo,
      ) async {
    try {
      final contacts = await getEmergencyContacts();

      for (final contact in contacts) {
        // Create notification record
        await _firestore.collection('notifications').add({
          'recipientPhone': contact.phoneNumber,
          'recipientName': contact.name,
          'senderUserId': currentUserId,
          'type': 'emergency_alert',
          'emergencyType': type,
          'location': location,
          'message': 'Emergency alert: $type. $additionalInfo',
          'timestamp': FieldValue.serverTimestamp(),
          'sent': false,
        });
      }

      // Here you would typically trigger your SMS/push notification service
      print('Emergency notifications queued for ${contacts.length} contacts');
    } catch (e) {
      print('Error notifying emergency contacts: $e');
    }
  }

  // User Activity Logging
  static Future<void> logUserActivity(String action, Map<String, dynamic> data) async {
    try {
      if (currentUserId == null) return;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('activity_logs')
          .add({
        'action': action,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      });
    } catch (e) {
      print('Error logging user activity: $e');
    }
  }

  // User Profile Methods
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUserId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Medical Information Methods
  static Future<Map<String, dynamic>?> getMedicalInfo() async {
    try {
      if (currentUserId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('medical_info')
          .doc('primary')
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting medical info: $e');
      return null;
    }
  }

  static Future<void> updateMedicalInfo(Map<String, dynamic> medicalData) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('medical_info')
          .doc('primary')
          .set({
        ...medicalData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating medical info: $e');
      rethrow;
    }
  }

  // Authentication helper methods
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}