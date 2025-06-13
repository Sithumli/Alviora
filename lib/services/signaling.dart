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
  bool _remoteDescriptionSet = false;
  Function(RTCPeerConnectionState)? onConnectionStateChanged;
  StreamSubscription? _roomSubscription;
  StreamSubscription? _callerCandidatesSubscription;
  StreamSubscription? _calleeCandidatesSubscription;
  bool _isDisposed = false;
  MediaStream? _localStream;

  Signaling({
    required this.localRenderer,
    required this.remoteRenderer,
    this.onConnectionStateChanged,
  });

  Future<void> _openUserMedia() async {
    try {
      // Request permissions first
      await [Permission.camera, Permission.microphone].request();

      if (!await Permission.camera.isGranted || !await Permission.microphone.isGranted) {
        throw Exception('Camera or microphone permission not granted');
      }

      final stream = await navigator.mediaDevices.getUserMedia({
        'video': {
          'width': 640,
          'height': 480,
          'frameRate': 30,
          'facingMode': 'user',
        },
        'audio': true,
      });

      _localStream = stream;
      localRenderer.srcObject = stream;
    } catch (e) {
      print('Error accessing media devices: $e');
      rethrow;
    }
  }

  Future<void> createRoom() async {
    if (_isDisposed) return;

    try {
      await _openUserMedia();

      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {
            'urls': 'turn:numb.viagenie.ca',
            'credential': 'muazkh',
            'username': 'webrtc@live.com'
          },
        ],
        'sdpSemantics': 'unified-plan'
      };

      peerConnection = await createPeerConnection(configuration);
      _setupPeerConnectionEventHandlers();

      _localStream?.getTracks().forEach((track) {
        peerConnection!.addTrack(track, _localStream!);
      });

      final roomRef = _firestore.collection('calls').doc();
      roomId = roomRef.id;

      // Create offer
      final offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);

      await roomRef.set({
        'offer': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Listen for ICE candidates
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) async {
        if (candidate == null || _isDisposed) return;
        await roomRef.collection('callerCandidates').add(candidate.toMap());
      };

      // Listen for remote answer
      _roomSubscription = roomRef.snapshots().listen((snapshot) async {
        if (_isDisposed || !snapshot.exists || _remoteDescriptionSet) return;

        final data = snapshot.data();
        if (data?.containsKey('answer') ?? false) {
          final answer = data!['answer'];
          await peerConnection!.setRemoteDescription(
              RTCSessionDescription(answer['sdp'], answer['type'])
          );
          _remoteDescriptionSet = true;
        }
      });

      // Listen for callee ICE candidates
      _calleeCandidatesSubscription = roomRef
          .collection('calleeCandidates')
          .snapshots()
          .listen((snapshot) {
        if (_isDisposed) return;
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data()!;
            peerConnection!.addCandidate(RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ));
          }
        });
      });

    } catch (e) {
      print('Error creating room: $e');
      await cleanup();
      rethrow;
    }
  }

  Future<void> joinRoom(String roomId) async {
    if (_isDisposed) return;

    try {
      await _openUserMedia();
      final roomRef = _firestore.collection('calls').doc(roomId);
      final roomSnapshot = await roomRef.get();

      if (!roomSnapshot.exists) {
        throw Exception('Room does not exist');
      }

      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {
            'urls': 'turn:numb.viagenie.ca',
            'credential': 'muazkh',
            'username': 'webrtc@live.com'
          },
        ],
        'sdpSemantics': 'unified-plan'
      };

      peerConnection = await createPeerConnection(configuration);
      _setupPeerConnectionEventHandlers();

      _localStream?.getTracks().forEach((track) {
        peerConnection!.addTrack(track, _localStream!);
      });

      // Set remote description from offer
      final offer = roomSnapshot.data()!['offer'];
      await peerConnection!.setRemoteDescription(
          RTCSessionDescription(offer['sdp'], offer['type'])
      );

      // Create answer
      final answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);

      await roomRef.update({
        'answer': {
          'type': answer.type,
          'sdp': answer.sdp,
        }
      });

      // Listen for ICE candidates
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) async {
        if (candidate == null || _isDisposed) return;
        await roomRef.collection('calleeCandidates').add(candidate.toMap());
      };

      // Listen for caller ICE candidates
      _callerCandidatesSubscription = roomRef
          .collection('callerCandidates')
          .snapshots()
          .listen((snapshot) {
        if (_isDisposed) return;
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data()!;
            peerConnection!.addCandidate(RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ));
          }
        });
      });

    } catch (e) {
      print('Error joining room: $e');
      await cleanup();
      rethrow;
    }
  }

  void _setupPeerConnectionEventHandlers() {
    peerConnection!.onConnectionState = (state) {
      if (_isDisposed) return;
      print('Connection state changed: $state');
      onConnectionStateChanged?.call(state);
    };

    peerConnection!.onIceConnectionState = (state) {
      print('ICE connection state changed: $state');
      // Handle ICE connection failures
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        onConnectionStateChanged?.call(RTCPeerConnectionState.RTCPeerConnectionStateDisconnected);
      }
    };

    peerConnection!.onTrack = (RTCTrackEvent event) {
      if (_isDisposed) return;
      if (event.streams.isNotEmpty && remoteRenderer.srcObject != event.streams[0]) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };
  }

  Future<void> endCall() async {
    if (roomId != null) {
      try {
        await _firestore.collection('calls').doc(roomId).delete();
      } catch (e) {
        print('Error deleting room: $e');
      }
    }
    await cleanup();
  }

  Future<void> cleanup() async {
    _isDisposed = true;

    await _roomSubscription?.cancel();
    await _callerCandidatesSubscription?.cancel();
    await _calleeCandidatesSubscription?.cancel();

    if (peerConnection != null) {
      await peerConnection!.close();
    }

    _localStream?.getTracks().forEach((track) => track.stop());
    remoteRenderer.srcObject?.getTracks().forEach((track) => track.stop());

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    _localStream = null;

    _remoteDescriptionSet = false;
    roomId = null;
    peerConnection = null;
  }

  void dispose() {
    cleanup();
  }
}