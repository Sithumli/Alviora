import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FullScreenAlertPage extends StatefulWidget {
  final String title;
  final String body;
  final String taskType;
  final String? taskId;

  const FullScreenAlertPage({
    super.key, 
    required this.title, 
    required this.body,
    required this.taskType,
    this.taskId,
  });

  @override
  State<FullScreenAlertPage> createState() => _FullScreenAlertPageState();
}

class _FullScreenAlertPageState extends State<FullScreenAlertPage> {
  final player = AudioPlayer();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _playNotificationSound();
  }

  Future<void> _playNotificationSound() async {
    try {
      await player.setAsset('assets/sounds/notification.mp3');
      await player.play();
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  Future<void> _updateTaskStatus(String status) async {
    if (widget.taskId == null) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final now = FieldValue.serverTimestamp();
      
      // Create a task_status collection to track all task statuses
      await firestore.collection('task_status').add({
        'taskId': widget.taskId,
        'taskType': widget.taskType,
        'title': widget.title,
        'status': status,
        'timestamp': now,
        'notes': widget.body,
      });
      
      // Update the original task collection based on task type
      switch (widget.taskType) {
        case 'medication':
          await firestore.collection('medications').doc(widget.taskId).update({
            'status': status,
            'lastStatus': status,
            'lastUpdated': now,
          });
          break;
          
        case 'quick_breathing':
        case 'deep_breathing':
          final collection = widget.taskType == 'quick_breathing' 
              ? 'quick_breathing_schedules' 
              : 'deep_breathing_schedules';
          await firestore.collection(collection).doc(widget.taskId).update({
            'status': status,
            'lastStatus': status,
            'lastUpdated': now,
          });
          break;
          
        case 'water':
          await firestore.collection('water_intake_logs').add({
            'timestamp': now,
            'cups': 1,
            'status': status,
            'userId': FirebaseFirestore.instance.collection('health_alerts').doc('9C49NtsHl0TajBKTDzEIoSV4oNZ2').id,
          });
          break;
          
        case 'schedule':
          await firestore.collection('schedules').doc(widget.taskId).update({
            'status': status,
            'lastStatus': status,
            'lastUpdated': now,
          });
          break;
      }
    } catch (e) {
      print('Error updating task status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Card(
          color: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          margin: const EdgeInsets.all(30),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTaskIcon(),
                  size: 80,
                  color: _getTaskColor(),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.body,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.skip_next),
                      label: Text("Skip"),
                      onPressed: _isUpdating ? null : () => _updateTaskStatus('Skipped'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.done),
                      label: Text(_isUpdating ? "Updating..." : "Mark Done"),
                      onPressed: _isUpdating ? null : () => _updateTaskStatus('Completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTaskIcon() {
    switch (widget.taskType) {
      case 'medication':
        return Icons.medication;
      case 'quick_breathing':
        return Icons.air;
      case 'deep_breathing':
        return Icons.spa;
      case 'water':
        return Icons.local_drink;
      case 'schedule':
        return Icons.event_note;
      default:
        return Icons.alarm;
    }
  }

  Color _getTaskColor() {
    switch (widget.taskType) {
      case 'medication':
        return Colors.blue;
      case 'quick_breathing':
        return Colors.teal;
      case 'deep_breathing':
        return Colors.purple;
      case 'water':
        return Colors.lightBlue;
      case 'schedule':
        return Colors.orange;
      default:
        return Colors.redAccent;
    }
  }
}
