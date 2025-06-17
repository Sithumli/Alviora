import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'notification_service.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final _notificationService = NotificationService();
  StreamSubscription? _medicationsSubscription;
  StreamSubscription? _quickBreathingSubscription;
  StreamSubscription? _deepBreathingSubscription;
  StreamSubscription? _schedulesSubscription;
  StreamSubscription? _waterSubscription;

  void initialize() {
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
  }

  void _handleMedicationsUpdate(QuerySnapshot snapshot) {
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
  }

  void _handleQuickBreathingUpdate(QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'Completed' && data['status'] != 'Skipped') {
        final scheduledDateTime = (data['scheduledDateTime'] as Timestamp?)?.toDate().toLocal();
        final durationMinutes = data['durationMinutes'] ?? 0;
        
        if (scheduledDateTime != null && scheduledDateTime.isAfter(DateTime.now())) {
          final title = "Quick Breathing (${durationMinutes} min)";
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
  }

  void _handleDeepBreathingUpdate(QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'Completed' && data['status'] != 'Skipped') {
        final scheduledDateTime = (data['scheduledDateTime'] as Timestamp?)?.toDate().toLocal();
        final durationMinutes = data['durationMinutes'] ?? 0;
        
        if (scheduledDateTime != null && scheduledDateTime.isAfter(DateTime.now())) {
          final title = "Deep Breathing (${durationMinutes} min)";
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
  }

  void _handleSchedulesUpdate(QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'Completed' && data['status'] != 'Skipped') {
        final fromTime = DateTime.tryParse("${data['date']}T${data['from']}");
        if (fromTime != null && fromTime.isAfter(DateTime.now())) {
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
  }

  void _handleWaterUpdate(Map<String, dynamic> data) {
    final cups = data['dailyWaterIntake'] ?? 0;
    if (cups > 0) {
      final today = DateTime.now();
      final startHour = 8;
      final endHour = 20;
      final interval = ((endHour - startHour) * 60) ~/ cups;

      for (int i = 0; i < cups; i++) {
        final scheduled = DateTime(today.year, today.month, today.day, startHour)
            .add(Duration(minutes: i * interval));
        
        if (scheduled.isAfter(DateTime.now())) {
          final title = "Drink Water (Cup ${i + 1}/$cups)";
          _notificationService.scheduleAlert(
            title,
            scheduled,
            taskType: 'water',
            taskId: 'water_${i + 1}',
            additionalInfo: "Stay hydrated! Cup ${i + 1} of $cups",
          );
        }
      }
    }
  }

  void dispose() {
    _medicationsSubscription?.cancel();
    _quickBreathingSubscription?.cancel();
    _deepBreathingSubscription?.cancel();
    _schedulesSubscription?.cancel();
    _waterSubscription?.cancel();
  }
} 