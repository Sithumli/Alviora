import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  final String callerId;
  final bool isIncoming;

  const CallScreen({
    Key? key,
    required this.callId,
    required this.callerId,
    this.isIncoming = true,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  bool _isCallActive = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isIncoming) {
      _isCallActive = true;
    }
  }

  void _handleAcceptCall() async {
    await _callService.updateCallStatus(widget.callId, 'accepted');
    setState(() {
      _isCallActive = true;
    });
  }

  void _handleDeclineCall() async {
    await _callService.updateCallStatus(widget.callId, 'declined');
    Navigator.of(context).pop();
  }

  void _handleEndCall() async {
    await _callService.endCall(widget.callId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
              Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFF90C3FD)
                  : Colors.blueGrey[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              ),
              const SizedBox(height: 20),
              Text(
                widget.isIncoming ? 'Incoming Call' : 'Calling...',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'From: ${widget.callerId}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              if (widget.isIncoming && !_isCallActive)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCallButton(
                      icon: Icons.call,
                      color: Colors.green,
                      onPressed: _handleAcceptCall,
                    ),
                    const SizedBox(width: 20),
                    _buildCallButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      onPressed: _handleDeclineCall,
                    ),
                  ],
                )
              else
                _buildCallButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onPressed: _handleEndCall,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: color,
      child: Icon(icon),
    );
  }
}