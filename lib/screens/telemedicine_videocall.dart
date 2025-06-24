import 'package:flutter/material.dart';
import 'dart:async';

class VideoCallPage extends StatefulWidget {
  final String? doctorName;
  final String? specialization;

  const VideoCallPage({Key? key, this.doctorName, this.specialization})
      : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool isConnecting = true;
  bool isMicOn = true;
  bool isCamOn = true;

  final Color primaryColor = Color(0xFF368FF5); // match Telemedicine Hub

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isConnecting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Dr. ${widget.doctorName ?? 'Doctor'}",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isConnecting
          ? _buildConnectingScreen()
          : Stack(
        children: [
          _buildFakeVideoFeed(),
          _buildSmallDoctorPreview(),
          _buildBottomControls(),
          _buildChatSection(),
        ],
      ),
    );
  }

  Widget _buildConnectingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 16),
          Text(
            "Connecting to video call...",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeVideoFeed() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Text(
          "Your Camera Feed",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildSmallDoctorPreview() {
    return Positioned(
      top: 20,
      right: 16,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            "Dr. ${widget.doctorName ?? 'Doctor'}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(
            icon: isMicOn ? Icons.mic : Icons.mic_off,
            color: isMicOn ? primaryColor : Colors.grey,
            onTap: () => setState(() => isMicOn = !isMicOn),
          ),
          _controlButton(
            icon: Icons.call_end,
            color: Colors.red,
            onTap: () => Navigator.pop(context),
          ),
          _controlButton(
            icon: isCamOn ? Icons.videocam : Icons.videocam_off,
            color: isCamOn ? primaryColor : Colors.grey,
            onTap: () => setState(() => isCamOn = !isCamOn),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 30,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildChatSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.send, color: primaryColor),
          ],
        ),
      ),
    );
  }
}
