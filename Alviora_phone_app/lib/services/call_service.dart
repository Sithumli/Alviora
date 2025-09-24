import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Listen for incoming calls
  Stream<DocumentSnapshot> listenForIncomingCalls(String userId) {
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.first);
  }

  // Update call status
  Future<void> updateCallStatus(String callId, String status) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating call status: $e');
    }
  }

  // Get call details
  Future<DocumentSnapshot> getCallDetails(String callId) async {
    try {
      return await _firestore.collection('calls').doc(callId).get();
    } catch (e) {
      print('Error getting call details: $e');
      rethrow;
    }
  }

  // End call
  Future<void> endCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error ending call: $e');
    }
  }
} 