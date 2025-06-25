import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> updateFCMToken(String userId, String? token) async {
    if (token == null) return;
    
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<String?> getFCMTokenForUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.get('fcmToken') as String?;
    } catch (e) {
      print('Error getting FCM token for user: $e');
      return null;
    }
  }
} 