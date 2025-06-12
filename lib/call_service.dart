import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

class CallService {
  final _firestore = FirebaseFirestore.instance;

  Future<String> startCall() async {
    final callDoc = _firestore.collection('calls').doc();

    final pc = await createNewPeerConnection();

    final localStream = await rtc.navigator.mediaDevices.getUserMedia({
      'audio': true, 'video': true,
    });
    for (var track in localStream.getTracks()) {
      pc.addTrack(track, localStream);
    }

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    await callDoc.set({'offer': offer.toMap()});

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        callDoc.collection('offerCandidates').add(e.toMap());
      }
    };

    callDoc.collection('answerCandidates').snapshots().listen((snap) {
      for (var doc in snap.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data()!;
          pc.addCandidate(
            rtc.RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });

    callDoc.snapshots().listen((snap) async {
      final data = snap.data();
      if (data != null && data['answer'] != null) {
        await pc.setRemoteDescription(
          rtc.RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
        );
      }
    });

    // Send FCM to callee
    final token = 'callee_device_token_here'; // store/retrieve this securely
    await FirebaseMessaging.instance.sendMessage(
      to: token,
      data: {'type': 'incoming_call', 'callId': callDoc.id},
    );

    return callDoc.id;
  }

  Future<rtc.RTCPeerConnection> createNewPeerConnection() async {
    return await rtc.createPeerConnection({
      'iceServers': [
        {'urls': ['stun:stun.l.google.com:19302']}
      ],
    });
  }
}
