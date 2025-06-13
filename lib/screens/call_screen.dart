import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/signaling.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final RTCVideoRenderer _localRenderer;
  late final RTCVideoRenderer _remoteRenderer;
  late final Signaling _signaling;
  final TextEditingController _roomIdController = TextEditingController();
  bool _inCall = false;

  @override
  void initState() {
    super.initState();
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    _initialize();
  }

  Future<void> _initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _signaling = Signaling(
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.hangUp();
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RTCVideoView(_remoteRenderer),
                Positioned(
                  right: 20,
                  bottom: 20,
                  width: 120,
                  height: 160,
                  child: RTCVideoView(_localRenderer, mirror: true),
                ),
              ],
            ),
          ),
          if (!_inCall) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Room ID',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _signaling.createRoom();
                    setState(() {
                      _roomIdController.text = _signaling.roomId!;
                      _inCall = true;
                    });
                  },
                  child: const Text('Create Room'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _signaling.joinRoom(_roomIdController.text);
                    setState(() => _inCall = true);
                  },
                  child: const Text('Join Room'),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () async {
                await _signaling.hangUp();
                setState(() => _inCall = false);
              },
              child: const Text('End Call'),
            ),
          ],
        ],
      ),
    );
  }
}