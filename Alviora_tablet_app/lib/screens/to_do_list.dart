import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:async';
import '../FullScreenAlertPage.dart';
import '../main.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;
  final _notificationService = NotificationService();
  StreamSubscription? _medicationsSubscription;
  StreamSubscription? _quickBreathingSubscription;
  StreamSubscription? _deepBreathingSubscription;
  StreamSubscription? _schedulesSubscription;
  StreamSubscription? _waterSubscription;
  StreamSubscription? _meditationSessionsSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealTimeListeners();
  }

  void _setupRealTimeListeners() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final startOfNextDay = startOfDay.add(const Duration(days: 1));

    // Listen to medications
    _medicationsSubscription = FirebaseFirestore.instance
        .collection('medications')
        .where('datetime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('datetime', isLessThan: startOfNextDay.toIso8601String())
        .snapshots()
        .listen((snapshot) {
      _handleMedicationsUpdate(snapshot);
    });

    // Listen to quick breathing
    _quickBreathingSubscription = FirebaseFirestore.instance
        .collection('quick_breathing_schedules')
        .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledDateTime', isLessThan: Timestamp.fromDate(startOfNextDay))
        .snapshots()
        .listen((snapshot) {
      _handleQuickBreathingUpdate(snapshot);
    });

    // Listen to deep breathing
    _deepBreathingSubscription = FirebaseFirestore.instance
        .collection('deep_breathing_schedules')
        .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledDateTime', isLessThan: Timestamp.fromDate(startOfNextDay))
        .snapshots()
        .listen((snapshot) {
      _handleDeepBreathingUpdate(snapshot);
    });

    // Listen to schedules
    _schedulesSubscription = FirebaseFirestore.instance
        .collection('schedules')
        .where('date', isEqualTo: "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}")
        .snapshots()
        .listen((snapshot) {
      _handleSchedulesUpdate(snapshot);
    });

    // Listen to water intake settings
    _waterSubscription = FirebaseFirestore.instance
        .collection('health_alerts')
        .doc('9C49NtsHl0TajBKTDzEIoSV4oNZ2')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _handleWaterUpdate(snapshot.data()!);
      }
    });

    // Listen to meditation sessions
    _meditationSessionsSubscription = FirebaseFirestore.instance
        .collection('meditation_sessions')
        .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledDateTime', isLessThan: Timestamp.fromDate(startOfNextDay))
        .snapshots()
        .listen((snapshot) {
      _handleMeditationSessionsUpdate(snapshot);
    });
  }

  void _handleMedicationsUpdate(QuerySnapshot snapshot) {
    final List<Map<String, dynamic>> newTasks = [];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'Completed' && data['status'] != 'Skipped') {
        final rawDatetime = DateTime.tryParse(data['datetime'] ?? '');
        if (rawDatetime != null) {
          final now = DateTime.now();
          final datetime = DateTime(
            now.year,
            rawDatetime.month,
            rawDatetime.day,
            rawDatetime.hour,
            rawDatetime.minute,
          );
          
          if (datetime.isAfter(DateTime.now())) {
            newTasks.add({
              'icon': Icons.medication,
              'title': data['title'] ?? 'Medication',
              'status': data['status'] ?? 'Upcoming',
              'time': datetime.toLocal().toString().substring(11, 16),
              'details': [
                "Scheduled for: ${datetime.toLocal().toString().substring(0, 16)}",
                "Status: ${data['status'] ?? 'Upcoming'}",
                if (data['notes'] != null) "Notes: ${data['notes']}",
              ],
            });
            
            _notificationService.scheduleAlert(
              data['title'] ?? 'Medication',
              datetime,
              taskType: 'medication',
              taskId: doc.id,
              additionalInfo: "Time to take your medication",
            );
          }
        }
      }
    }
    _updateTasks(newTasks, 'medication');
  }

  void _handleQuickBreathingUpdate(QuerySnapshot snapshot) {
    final List<Map<String, dynamic>> newTasks = [];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'Completed' && data['status'] != 'Skipped') {
        final scheduledDateTime = (data['scheduledDateTime'] as Timestamp?)?.toDate().toLocal();
        final durationMinutes = data['durationMinutes'] ?? 0;
        
        if (scheduledDateTime != null && scheduledDateTime.isAfter(DateTime.now())) {
          final title = "Quick Breathing (${durationMinutes} min)";
          newTasks.add({
            'icon': Icons.air,
            'title': title,
            'status': data['recurrence'] ?? 'One-time',
            'time': scheduledDateTime.toString().substring(11, 16),
            'details': [
              "Duration: ${durationMinutes} minutes",
              "Recurrence: ${data['recurrence'] ?? 'N/A'}",
              "Scheduled: ${scheduledDateTime.toString().substring(0, 16)}",
            ],
          });
          
          _notificationService.scheduleAlert(
            title,
            scheduledDateTime,
            taskType: 'quick_breathing',
            taskId: doc.id,
            additionalInfo: "Duration: ${durationMinutes} minutes",
          );
        }
      }
    }
    _updateTasks(newTasks, 'quick_breathing');
  }

  void _handleDeepBreathingUpdate(QuerySnapshot snapshot) {
    final List<Map<String, dynamic>> newTasks = [];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'Completed' && data['status'] != 'Skipped') {
        final scheduledDateTime = (data['scheduledDateTime'] as Timestamp?)?.toDate().toLocal();
        final durationMinutes = data['durationMinutes'] ?? 0;
        
        if (scheduledDateTime != null && scheduledDateTime.isAfter(DateTime.now())) {
          final title = "Deep Breathing (${durationMinutes} min)";
          newTasks.add({
            'icon': Icons.spa,
            'title': title,
            'status': data['recurrence'] ?? 'One-time',
            'time': scheduledDateTime.toString().substring(11, 16),
            'details': [
              "Duration: ${durationMinutes} minutes",
              "Recurrence: ${data['recurrence'] ?? 'N/A'}",
              "Scheduled: ${scheduledDateTime.toString().substring(0, 16)}",
            ],
          });
          
          _notificationService.scheduleAlert(
            title,
            scheduledDateTime,
            taskType: 'deep_breathing',
            taskId: doc.id,
            additionalInfo: "Duration: ${durationMinutes} minutes",
          );
        }
      }
    }
    _updateTasks(newTasks, 'deep_breathing');
  }

  void _handleSchedulesUpdate(QuerySnapshot snapshot) {
    final List<Map<String, dynamic>> newTasks = [];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'Completed' && data['status'] != 'Skipped') {
        final fromTime = DateTime.tryParse("${data['date']}T${data['from']}");
        if (fromTime != null && fromTime.isAfter(DateTime.now())) {
          newTasks.add({
            'icon': Icons.event_note,
            'title': data['description'] ?? 'No Description',
            'status': data['hasEvent'] == true ? 'Scheduled' : 'Not Scheduled',
            'time': "${data['from']} - ${data['to']}",
            'details': [
              "From: ${data['from'] ?? 'N/A'}",
              "To: ${data['to'] ?? 'N/A'}",
              "Created at: ${data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate().toLocal().toString().substring(0, 16) : 'N/A'}",
            ],
          });
          
          _notificationService.scheduleAlert(
            data['description'] ?? 'Task Reminder',
            fromTime,
            taskType: 'schedule',
            taskId: doc.id,
            additionalInfo: "From ${data['from']} to ${data['to']}",
          );
        }
      }
    }
    _updateTasks(newTasks, 'schedule');
  }

  void _handleWaterUpdate(Map<String, dynamic> data) {
    final cups = data['dailyWaterIntake'] ?? 0;
    if (cups > 0) {
      final List<Map<String, dynamic>> newTasks = [];
      final today = DateTime.now();
      final startHour = 8;
      final endHour = 20;
      final interval = ((endHour - startHour) * 60) ~/ cups;

      for (int i = 0; i < cups; i++) {
        final scheduled = DateTime(today.year, today.month, today.day, startHour)
            .add(Duration(minutes: i * interval));
        
        if (scheduled.isAfter(DateTime.now())) {
          final title = "Drink Water (Cup ${i + 1}/$cups)";
          newTasks.add({
            'icon': Icons.local_drink,
            'title': title,
            'status': 'Hydration',
            'time': "${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}",
            'details': [
              "Auto spaced based on $cups cups",
              "Hydration scheduled at ${scheduled.toLocal().toString().substring(0, 16)}",
            ],
          });
          
          _notificationService.scheduleAlert(
            title,
            scheduled,
            taskType: 'water',
            taskId: 'water_${i + 1}',
            additionalInfo: "Stay hydrated! Cup ${i + 1} of $cups",
          );
        }
      }
      _updateTasks(newTasks, 'water');
    }
  }

  void _handleMeditationSessionsUpdate(QuerySnapshot snapshot) {
    final List<Map<String, dynamic>> newTasks = [];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'Completed' && data['status'] != 'Skipped') {
        final scheduledDateTime = (data['scheduledDateTime'] as Timestamp?)?.toDate().toLocal();
        final meditationType = data['meditationType'] ?? 'Meditation';
        final frequency = data['frequency'] ?? 'Once';
        if (scheduledDateTime != null && scheduledDateTime.isAfter(DateTime.now())) {
          newTasks.add({
            'icon': Icons.self_improvement,
            'title': meditationType,
            'status': frequency,
            'time': scheduledDateTime.toString().substring(11, 16),
            'details': [
              "Scheduled: ${scheduledDateTime.toString().substring(0, 16)}",
              "Frequency: $frequency",
            ],
          });
          _notificationService.scheduleAlert(
            meditationType,
            scheduledDateTime,
            taskType: 'meditation',
            taskId: doc.id,
            additionalInfo: "Time for your meditation session",
          );
        }
      }
    }
    _updateTasks(newTasks, 'meditation');
  }

  void _updateTasks(List<Map<String, dynamic>> newTasks, String taskType) {
    setState(() {
      // Remove old tasks of this type
      tasks.removeWhere((task) => task['taskType'] == taskType);
      // Add new tasks
      tasks.addAll(newTasks.map((task) => {...task, 'taskType': taskType}));
      // Sort tasks by time
      tasks.sort((a, b) => a['time'].compareTo(b['time']));
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _medicationsSubscription?.cancel();
    _quickBreathingSubscription?.cancel();
    _deepBreathingSubscription?.cancel();
    _schedulesSubscription?.cancel();
    _waterSubscription?.cancel();
    _meditationSessionsSubscription?.cancel();
    super.dispose();
  }

  Widget buildTaskCard({
    required IconData icon,
    required String title,
    required String status,
    required String time,
    required List<String> details,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Icon(icon, size: 32, color: Colors.blueAccent),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 70,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blueAccent, width: 1.5),
            ),
            elevation: 4,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(time,
                        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(status, style: TextStyle(color: Colors.black54, fontSize: 16)),
              ),
              children: details
                  .map((detail) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                title: Row(
                  children: [
                    Icon(Icons.brightness_1, size: 10, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(child: Text(detail, style: TextStyle(fontSize: 18))),
                  ],
                ),
              ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios, size: 20),
                    label: Text("Go Back", style: TextStyle(fontSize: 18)),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "To ",
                        style: TextStyle(color: Colors.blue, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "Do\n",
                        style:
                        TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: "L I S T",
                        style:
                        TextStyle(letterSpacing: 8, color: Colors.blueAccent, fontSize: 18),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              if (tasks.isEmpty)
                Text("No tasks scheduled today.", style: TextStyle(fontSize: 18))
              else
                Column(
                  children: List.generate(tasks.length, (index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 26),
                      child: buildTaskCard(
                        icon: task["icon"],
                        title: task["title"],
                        status: task["status"],
                        time: task["time"],
                        details: List<String>.from(task["details"]),
                        isLast: index == tasks.length - 1,
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
