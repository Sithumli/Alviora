import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:alviora_app/services/signaling.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final TextEditingController _roomIdController = TextEditingController();
  late Signaling signaling;
  bool _isCreatingRoom = false;
  bool _isJoiningRoom = false;
  String _connectionState = '';
  bool _isInCall = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    if (!_isDisposed) {
      signaling = Signaling(
        localRenderer: _localRenderer,
        remoteRenderer: _remoteRenderer,
        onConnectionStateChanged: _onConnectionStateChanged,
      );
    }
  }

  void _onConnectionStateChanged(RTCPeerConnectionState state) {
    if (_isDisposed) return;
    
    setState(() {
      _connectionState = state.toString();
      _isInCall = state == RTCPeerConnectionState.RTCPeerConnectionStateConnected;
      
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _showError('Connection lost. Please try again.');
        _endCall();
      }
    });
  }

  void _showError(String message) {
    if (!_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    signaling.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_isCreatingRoom) return;
    
    setState(() {
      _isCreatingRoom = true;
      _connectionState = 'Creating room...';
    });

    try {
      await signaling.createRoom();
      if (!_isDisposed) {
        setState(() {
          _roomIdController.text = signaling.roomId ?? '';
          _connectionState = 'Waiting for peer to join...';
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Error creating room: $e');
        setState(() {
          _connectionState = 'Error creating room';
        });
      }
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isCreatingRoom = false;
        });
      }
    }
  }

  Future<void> _joinRoom() async {
    if (_isJoiningRoom) return;
    
    final roomId = _roomIdController.text.trim();
    if (roomId.isEmpty) {
      _showError('Please enter a Room ID');
      return;
    }

    setState(() {
      _isJoiningRoom = true;
      _connectionState = 'Joining room...';
    });

    try {
      await signaling.joinRoom(roomId);
      if (!_isDisposed) {
        setState(() {
          _connectionState = 'Connecting...';
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Error joining room: $e');
        setState(() {
          _connectionState = 'Error joining room';
        });
      }
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isJoiningRoom = false;
        });
      }
    }
  }

  Future<void> _endCall() async {
    try {
      await signaling.endCall();
    } catch (e) {
      print('Error ending call: $e');
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isInCall = false;
          _connectionState = '';
          _roomIdController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        actions: [
          if (_isInCall)
            IconButton(
              icon: const Icon(Icons.call_end),
              onPressed: _endCall,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_connectionState.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                _connectionState,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                RTCVideoView(_remoteRenderer),
                Positioned(
                  right: 20,
                  bottom: 20,
                  width: 120,
                  height: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: RTCVideoView(_localRenderer, mirror: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_isInCall) ...[
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
                  onPressed: _isCreatingRoom ? null : _createRoom,
                  child: _isCreatingRoom
                      ? const CircularProgressIndicator()
                      : const Text('Create Room'),
                ),
                ElevatedButton(
                  onPressed: _isJoiningRoom ? null : _joinRoom,
                  child: _isJoiningRoom
                      ? const CircularProgressIndicator()
                      : const Text('Join Room'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
