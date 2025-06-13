import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Signaling({
    required this.localRenderer, 
    required this.remoteRenderer,
    this.onConnectionStateChanged,
  }) {
    // Verify Firebase connection
    _verifyFirebaseConnection();
  }

  Future<void> _verifyFirebaseConnection() async {
    try {
      // Try to write a test document
      await _firestore.collection('test').doc('connection_test').set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Firebase connection successful');
      
      // Clean up test document
      await _firestore.collection('test').doc('connection_test').delete();
    } catch (e) {
      print('Firebase connection error: $e');
      rethrow;
    }
  }

  Future<void> _openUserMedia() async {
    try {
      final stream = await navigator.mediaDevices.getUserMedia({
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        },
        'audio': true,
      });
      localRenderer.srcObject = stream;
      print('Local media stream obtained successfully');
    } catch (e) {
      print('Error accessing media devices: $e');
      rethrow;
    }
  }

  Future<void> createRoom() async {
    try {
      print('Starting room creation...');
      await _openUserMedia();
      
      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          {'urls': 'stun:stun2.l.google.com:19302'},
          {'urls': 'stun:stun3.l.google.com:19302'},
          {'urls': 'stun:stun4.l.google.com:19302'},
        ],
        'sdpSemantics': 'unified-plan',
        'iceCandidatePoolSize': 10,
      };

      print('Creating peer connection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);
      print('Peer connection created successfully');

      // Set up connection state monitoring
      peerConnection!.onConnectionState = (state) {
        print('Connection state changed: $state');
        onConnectionStateChanged?.call(state);
      };

      peerConnection!.onIceConnectionState = (state) {
        print('ICE connection state changed: $state');
      };

      peerConnection!.onIceGatheringState = (state) {
        print('ICE gathering state changed: $state');
      };

      peerConnection!.onTrack = (RTCTrackEvent event) {
        print('Track received: ${event.track.id}');
        if (event.streams.isNotEmpty) {
          remoteRenderer.srcObject = event.streams[0];
          print('Remote stream set to renderer');
        }
      };

      localRenderer.srcObject!.getTracks().forEach((track) {
        print('Adding local track: ${track.id}');
        peerConnection!.addTrack(track, localRenderer.srcObject!);
      });

      final roomRef = _firestore.collection('calls').doc();
      roomId = roomRef.id;
      print('Created room with ID: $roomId');

      final offer = await peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      print('Created offer: ${offer.toMap()}');
      
      await peerConnection!.setLocalDescription(offer);
      print('Set local description');

      print('Saving room data to Firestore...');
      await roomRef.set({
        'offer': offer.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'waiting',
      });
      print('Room data saved to Firestore successfully');

      peerConnection!.onIceCandidate = (candidate) async {
        if (candidate != null) {
          print('New ICE candidate: ${candidate.candidate}');
          try {
            await roomRef.collection('callerCandidates').add(candidate.toMap());
            print('ICE candidate saved to Firestore');
          } catch (e) {
            print('Error saving ICE candidate: $e');
          }
        }
      };

      // Listen for remote answer
      print('Setting up room subscription...');
      _roomSubscription = roomRef.snapshots().listen((snapshot) async {
        final data = snapshot.data();
        print('Room data updated: ${data?.toString()}');
        
        if (data == null) return;
        if (_remoteDescriptionSet) return;

        if (data.containsKey('answer')) {
          try {
            print('Received answer from peer: ${data['answer']}');
            final answer = RTCSessionDescription(
              data['answer']['sdp'],
              data['answer']['type'],
            );
            await peerConnection!.setRemoteDescription(answer);
            _remoteDescriptionSet = true;
            print('Remote description set successfully');
            await roomRef.update({'status': 'connected'});
            print('Room status updated to connected');
          } catch (e) {
            print('Error setting remote description: $e');
            rethrow;
          }
        }
      });

      // Listen for callee ICE candidates
      print('Setting up callee candidates subscription...');
      _calleeCandidatesSubscription = roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
        print('Callee candidates updated: ${snapshot.docChanges.length} changes');
        for (var doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.added) {
            try {
              final candidateMap = doc.doc.data()!;
              print('Received callee ICE candidate: ${candidateMap['candidate']}');
              peerConnection!.addCandidate(RTCIceCandidate(
                candidateMap['candidate'],
                candidateMap['sdpMid'],
                candidateMap['sdpMLineIndex'],
              ));
              print('Callee ICE candidate added to peer connection');
            } catch (e) {
              print('Error adding callee ICE candidate: $e');
            }
          }
        }
      });
    } catch (e) {
      print('Error creating room: $e');
      await cleanup();
      rethrow;
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await _openUserMedia();
      final roomRef = _firestore.collection('calls').doc(roomId);
      final roomSnapshot = await roomRef.get();

      if (!roomSnapshot.exists) {
        throw Exception('Room does not exist');
      }

      print('Joining room: $roomId');

      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          {'urls': 'stun:stun2.l.google.com:19302'},
          {'urls': 'stun:stun3.l.google.com:19302'},
          {'urls': 'stun:stun4.l.google.com:19302'},
        ],
        'sdpSemantics': 'unified-plan',
        'iceCandidatePoolSize': 10,
      };

      peerConnection = await createPeerConnection(configuration);
      print('Peer connection created');

      // Set up connection state monitoring
      peerConnection!.onConnectionState = (state) {
        print('Connection state changed: $state');
        onConnectionStateChanged?.call(state);
      };

      peerConnection!.onIceConnectionState = (state) {
        print('ICE connection state changed: $state');
      };

      peerConnection!.onIceGatheringState = (state) {
        print('ICE gathering state changed: $state');
      };

      peerConnection!.onTrack = (RTCTrackEvent event) {
        print('Track received: ${event.track.id}');
        if (event.streams.isNotEmpty) {
          remoteRenderer.srcObject = event.streams[0];
          print('Remote stream set to renderer');
        }
      };

      localRenderer.srcObject!.getTracks().forEach((track) {
        print('Adding local track: ${track.id}');
        peerConnection!.addTrack(track, localRenderer.srcObject!);
      });

      final offer = roomSnapshot['offer'];
      try {
        print('Setting remote description from offer');
        await peerConnection!.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));
        _remoteDescriptionSet = true;
        print('Remote description set successfully');
      } catch (e) {
        print('Error setting remote description: $e');
        rethrow;
      }

      final answer = await peerConnection!.createAnswer();
      print('Created answer');
      await peerConnection!.setLocalDescription(answer);
      print('Set local description');

      await roomRef.update({
        'answer': answer.toMap(),
        'status': 'connecting',
      });
      print('Answer saved to Firestore');

      peerConnection!.onIceCandidate = (candidate) async {
        if (candidate != null) {
          print('New ICE candidate: ${candidate.candidate}');
          await roomRef.collection('calleeCandidates').add(candidate.toMap());
        }
      };

      _callerCandidatesSubscription = roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        for (var doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.added) {
            try {
              final data = doc.doc.data()!;
              print('Received caller ICE candidate: ${data['candidate']}');
              peerConnection!.addCandidate(RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ));
            } catch (e) {
              print('Error adding caller ICE candidate: $e');
            }
          }
        }
      });
    } catch (e) {
      print('Error joining room: $e');
      await cleanup();
      rethrow;
    }
  }

  Future<void> endCall() async {
    try {
      if (roomId != null) {
        final roomRef = _firestore.collection('calls').doc(roomId);
        await roomRef.update({'status': 'ended'});
      }
    } catch (e) {
      print('Error ending call: $e');
    } finally {
      await cleanup();
    }
  }

  Future<void> cleanup() async {
    print('Cleaning up resources');
    _roomSubscription?.cancel();
    _callerCandidatesSubscription?.cancel();
    _calleeCandidatesSubscription?.cancel();
    
    peerConnection?.close();
    localRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    remoteRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    
    _remoteDescriptionSet = false;
    roomId = null;
    print('Cleanup completed');
  }

  void dispose() {
    cleanup();
  }
}
