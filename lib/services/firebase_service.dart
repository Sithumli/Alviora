import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency_contact_model.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid ?? 'anonymous_user';

  // Emergency Contacts Methods
  static Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
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
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(userId)
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
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final DatabaseReference alertsRef = FirebaseDatabase.instance.ref('alerts');
      final now = DateTime.now();
      final alertData = {
        'action_required': true,
        'actions': {
          'call_emergency': true,
          'dismiss': true,
          'view_360': true,
        },
        'details': {
          'count': 1,
          'window_minutes': 1,
        },
        'emergency_number': type == 'medical' || type == 'fire' || type == 'police' ? '911' : '',
        'message': additionalInfo,
        'severity': 'high',
        'sound': 'alert_sound.mp3',
        'status': 'active',
        'timestamp': now.toIso8601String(),
        'title': type == 'medical' ? 'Medical Emergency' : type == 'fire' ? 'Fire Emergency' : type == 'police' ? 'Police Emergency' : 'Emergency',
        'type': type,
        'userId': userId,
        'location': location,
      };

      // Write to Realtime Database
      await alertsRef.push().set(alertData);

      // Optionally, you can still log activity or notify contacts as before
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
      final userId = currentUserId;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activity_logs')
          .add({
        'action': action,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
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
