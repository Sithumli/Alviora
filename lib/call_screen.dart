import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'call_service.dart';



class CallScreen extends StatefulWidget {
  final String callId;
  const CallScreen({super.key, required this.callId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;
  late RTCPeerConnection _pc;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _joinCall();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _pc.close();
    super.dispose();
  }

  void _initRenderers() async {
    _localRenderer = RTCVideoRenderer()..initialize();
    _remoteRenderer = RTCVideoRenderer()..initialize();
  }

  Future<void> _joinCall() async {
    final callDoc = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId);
    _pc = await CallService().createNewPeerConnection();

    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true, 'video': true,
    });
    stream.getTracks().forEach((t) => _pc.addTrack(t, stream));
    _localRenderer.srcObject = stream;

    final data = (await callDoc.get()).data()!;
    final offer = data['offer'];
    await _pc.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));

    final answer = await _pc.createAnswer();
    await _pc.setLocalDescription(answer);
    await callDoc.update({'answer': answer.toMap()});

    _pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        callDoc.collection('answerCandidates').add(e.toMap());
      }
    };

    _pc.onTrack = (ev) {
      setState(() {
        _remoteRenderer.srcObject = ev.streams[0];
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FF),
      appBar: AppBar(backgroundColor: const Color(0xFF5EA8FF), title: const Text('Family Call')),
      body: Stack(
        children: [
          RTCVideoView(_remoteRenderer),
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 120,
              height: 160,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0, right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _pc.close();
                  FirebaseFirestore.instance.collection('calls').doc(widget.callId).delete();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('End Call'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
