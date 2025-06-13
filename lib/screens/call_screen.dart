import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:alviora_app/services/signaling.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await [Permission.camera, Permission.microphone].request();
    setState(() {
      _hasPermissions = status[Permission.camera]!.isGranted &&
          status[Permission.microphone]!.isGranted;
    });
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
      _connectionState = _getConnectionStateString(state);
      _isInCall = state == RTCPeerConnectionState.RTCPeerConnectionStateConnected;

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _showError('Connection lost. Please try again.');
        _endCall();
      }
    });
  }

  String _getConnectionStateString(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateNew:
        return 'New';
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        return 'Connecting';
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        return 'Connected';
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        return 'Disconnected';
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        return 'Failed';
      case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  void _showError(String message) {
    if (!_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
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
    if (_isCreatingRoom || !_hasPermissions) return;

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
        String errorMessage = 'Error creating room: ';
        if (e.toString().contains('Timeout')) {
          errorMessage += 'No peer joined within 30 seconds. Please try again.';
        } else if (e.toString().contains('Failed to create peer connection')) {
          errorMessage += 'Could not establish WebRTC connection. Please check your internet connection.';
        } else if (e.toString().contains('Local media stream is null')) {
          errorMessage += 'Could not access camera/microphone. Please check permissions.';
        } else {
          errorMessage += e.toString();
        }
        _showError(errorMessage);
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
    if (_isJoiningRoom || !_hasPermissions) return;

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
        String errorMessage = 'Error joining room: ';
        if (e.toString().contains('Room does not exist')) {
          errorMessage += 'Invalid Room ID. Please check and try again.';
        } else if (e.toString().contains('Failed to create peer connection')) {
          errorMessage += 'Could not establish WebRTC connection. Please check your internet connection.';
        } else if (e.toString().contains('Local media stream is null')) {
          errorMessage += 'Could not access camera/microphone. Please check permissions.';
        } else {
          errorMessage += e.toString();
        }
        _showError(errorMessage);
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
              icon: const Icon(Icons.call_end, color: Colors.red),
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
          if (!_hasPermissions)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange,
              child: const Text(
                'Camera and microphone permissions are required',
                style: TextStyle(color: Colors.white),
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
                  onPressed: _isCreatingRoom || !_hasPermissions ? null : _createRoom,
                  child: _isCreatingRoom
                      ? const CircularProgressIndicator()
                      : const Text('Create Room'),
                ),
                ElevatedButton(
                  onPressed: _isJoiningRoom || !_hasPermissions ? null : _joinRoom,
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