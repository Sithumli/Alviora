import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class Signaling {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  RTCPeerConnection? peerConnection;
  String? roomId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _roomSubscription;
  StreamSubscription? _candidatesSubscription;

  Signaling({required this.localRenderer, required this.remoteRenderer});

  Future<void> _openUserMedia() async {
    await [Permission.camera, Permission.microphone].request();
    final stream = await navigator.mediaDevices.getUserMedia({
      'video': {'width': 640, 'height': 480},
      'audio': true
    });
    localRenderer.srcObject = stream;
  }

  Future<void> createRoom() async {
    await _openUserMedia();

    peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    });

    // Add local stream tracks
    localRenderer.srcObject?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localRenderer.srcObject!);
    });

    // Create room
    final roomRef = _firestore.collection('rooms').doc();
    roomId = roomRef.id;

    // Create offer
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    await roomRef.set({'offer': offer.toMap()});

    // Listen for answer
    _roomSubscription = roomRef.snapshots().listen((snapshot) async {
      if (snapshot.data()?['answer'] != null) {
        final answer = RTCSessionDescription(
          snapshot.data()!['answer']['sdp'],
          snapshot.data()!['answer']['type'],
        );
        await peerConnection!.setRemoteDescription(answer);
      }
    });

    // Listen for ICE candidates
    peerConnection!.onIceCandidate = (candidate) async {
      if (candidate != null) {
        await roomRef.collection('callerCandidates').add(candidate.toMap());
      }
    };

    _candidatesSubscription = roomRef
        .collection('calleeCandidates')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
  }

  Future<void> joinRoom(String roomId) async {
    await _openUserMedia();

    peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    });

    // Add local stream tracks
    localRenderer.srcObject?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localRenderer.srcObject!);
    });

    final roomRef = _firestore.collection('rooms').doc(roomId);
    final roomSnapshot = await roomRef.get();

    if (!roomSnapshot.exists) throw Exception('Room not found');

    // Set remote offer
    final offer = roomSnapshot.data()!['offer'];
    await peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    // Create answer
    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    await roomRef.update({'answer': answer.toMap()});

    // Listen for ICE candidates
    peerConnection!.onIceCandidate = (candidate) async {
      if (candidate != null) {
        await roomRef.collection('calleeCandidates').add(candidate.toMap());
      }
    };

    _candidatesSubscription = roomRef
        .collection('callerCandidates')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
  }

  Future<void> hangUp() async {
    await peerConnection?.close();
    await _roomSubscription?.cancel();
    await _candidatesSubscription?.cancel();
    if (roomId != null) {
      await _firestore.collection('rooms').doc(roomId).delete();
    }
    localRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    remoteRenderer.srcObject?.getTracks().forEach((track) => track.stop());
  }
}