import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  final String? doctorName;
  final String? specialization;

  const VideoCallPage({
    Key? key,
    this.doctorName,
    this.specialization,
  }) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool isMuted = false;
  bool isVideoOn = true;
  bool isScreenSharing = false;
  bool isChatOpen = false;
  TextEditingController chatController = TextEditingController();
  List<ChatMessage> chatMessages = [];

  @override
  void initState() {
    super.initState();
    // Add some initial chat messages
    chatMessages = [
      ChatMessage(
        sender: widget.doctorName ?? 'Dr. Sarah Johnson',
        message: 'Hello! How are you feeling today?',
        isDoctor: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      ChatMessage(
        sender: 'You',
        message: 'Hi Doctor, I\'ve been having some headaches lately.',
        isDoctor: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 4)),
      ),
      ChatMessage(
        sender: widget.doctorName ?? 'Dr. Sarah Johnson',
        message: 'I see. Can you describe the frequency and intensity of these headaches?',
        isDoctor: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 3)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            // Main video area
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    // Main doctor video feed
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1200&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFE3F2FD),
                                    Color(0xFFBBDEFB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.medical_services,
                                        size: 60,
                                        color: Color(0xFF4A90E2),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      widget.doctorName ?? 'Dr. Sarah Johnson',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      widget.specialization ?? 'General Practitioner',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF7F8C8D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4A90E2).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Connected',
                                        style: TextStyle(
                                          color: Color(0xFF4A90E2),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Bottom control bar
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Color(0xFF2C3E50),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              icon: Icons.more_horiz,
                              onTap: () {},
                              backgroundColor: Colors.transparent,
                              iconColor: Colors.white,
                            ),
                            _buildControlButton(
                              icon: isMuted ? Icons.mic_off : Icons.mic,
                              onTap: () {
                                setState(() {
                                  isMuted = !isMuted;
                                });
                              },
                              backgroundColor: isMuted ? Colors.red : Colors.transparent,
                              iconColor: Colors.white,
                            ),
                            _buildControlButton(
                              icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                              onTap: () {
                                setState(() {
                                  isScreenSharing = !isScreenSharing;
                                });
                              },
                              backgroundColor: isScreenSharing ? Color(0xFF4A90E2) : Colors.transparent,
                              iconColor: Colors.white,
                            ),
                            _buildControlButton(
                              icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
                              onTap: () {
                                setState(() {
                                  isVideoOn = !isVideoOn;
                                });
                              },
                              backgroundColor: isVideoOn ? Colors.transparent : Colors.red,
                              iconColor: Colors.white,
                            ),
                            _buildControlButton(
                              icon: Icons.people,
                              onTap: () {},
                              backgroundColor: Colors.transparent,
                              iconColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right sidebar
            Container(
              width: 320,
              child: Column(
                children: [
                  // Chat with Doctor button
                  Container(
                    margin: EdgeInsets.all(12),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isChatOpen = !isChatOpen;
                        });
                      },
                      icon: Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                      label: Text(
                        'Chat with Doctor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A90E2),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),

                  // Chat area or Participants
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      child: isChatOpen ? _buildChatArea() : _buildParticipantsArea(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: backgroundColor == Colors.transparent
              ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildParticipantsArea() {
    return Column(
      children: [
        // Doctor participant
        _buildParticipantCard(
          name: 'Shenal. R',
          isDoctor: true,
          imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
        ),

        SizedBox(height: 16),

        // Patient participant (You)
        _buildParticipantCard(
          name: 'You',
          isDoctor: false,
          imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
        ),
      ],
    );
  }

  Widget _buildParticipantCard({
    required String name,
    required bool isDoctor,
    required String imageUrl,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDoctor
                            ? [Color(0xFF4A90E2), Color(0xFF357ABD)]
                            : [Color(0xFF95A5A6), Color(0xFF7F8C8D)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Name overlay
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.videocam,
                        color: Color(0xFF4A90E2),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.mic,
                        color: Color(0xFF4A90E2),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chat header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF4A90E2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isChatOpen = false;
                    });
                  },
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                return _buildChatMessage(chatMessages[index]);
              },
            ),
          ),

          // Chat input
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (value) => _sendMessage(value),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(chatController.text),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A90E2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: message.isDoctor ? Color(0xFF4A90E2) : Color(0xFF95A5A6),
            child: Icon(
              message.isDoctor ? Icons.medical_services : Icons.person,
              size: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.sender,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: message.isDoctor ? Color(0xFF4A90E2) : Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: message.isDoctor
                        ? Color(0xFF4A90E2).withOpacity(0.1)
                        : Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      chatMessages.add(
        ChatMessage(
          sender: 'You',
          message: text.trim(),
          isDoctor: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    chatController.clear();

    // Simulate doctor response after a delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          chatMessages.add(
            ChatMessage(
              sender: widget.doctorName ?? 'Dr. Sarah Johnson',
              message: 'Thank you for sharing that information. Let me review your symptoms.',
              isDoctor: true,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String sender;
  final String message;
  final bool isDoctor;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.isDoctor,
    required this.timestamp,
  });
}