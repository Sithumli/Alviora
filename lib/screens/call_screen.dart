import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String appId = 'aaf4a3b2344c49a39fd10705d5faebf3';
const String token = '007eJxTYKgp445zsPu97uq3VVvMpzz/7vy228Zdji9w25TD2ywXq1YoMCQmppkkGicZGZuYJJtYJhpbpqUYGpgbmKaYpiWmJqUZ2/b4ZDQEMjKkPVVjYWSAQBCfhyExpywzvygxPjkxJ4eBAQCpiSNe'; // or leave "" if token is off
const String channel = 'alviora_call';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final RtcEngine _engine;
  bool _joined = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (conn, elapsed) {
          setState(() => _joined = true);
        },
        onUserJoined: (conn, uid, elapsed) {
          setState(() => _remoteUid = uid);
        },
        onUserOffline: (conn, uid, reason) {
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _renderLocal() {
    return _joined
        ? AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _renderRemote() {
    if (_remoteUid == null) {
      return const Center(child: Text('Waiting for user...'));
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: const RtcConnection(channelId: channel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Stack(
        children: [
          Center(child: _renderRemote()),
          Positioned(
            top: 20,
            left: 20,
            width: 120,
            height: 160,
            child: _renderLocal(),
          ),
        ],
      ),
    );
  }
}
