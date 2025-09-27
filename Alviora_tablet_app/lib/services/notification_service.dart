import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:async';
import '../FullScreenAlertPage.dart';
import '../main.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final Map<String, Timer> _scheduledTimers = {};
  final Map<String, bool> _shownAlerts = {};

  Future<void> scheduleAlert(String title, DateTime scheduledTime, {
    required String taskType,
    required String taskId,
    String? additionalInfo,
  }) async {
    print('Attempting to schedule alert:');
    print('- Title: $title');
    print('- Scheduled Time: $scheduledTime');
    print('- Task Type: $taskType');
    print('- Task ID: $taskId');
    print('- Additional Info: $additionalInfo');

    if (scheduledTime.isBefore(DateTime.now())) {
      print('Skipping alert - scheduled time is in the past');
      return;
    }

    try {
      // Cancel any existing timer for this task
      _scheduledTimers[taskId]?.cancel();
      
      // Calculate delay until scheduled time
      final now = DateTime.now();
      final delay = scheduledTime.difference(now);
      
      if (delay.isNegative) {
        print('Skipping alert - scheduled time is in the past');
        return;
      }

      print('Scheduling alert for $title in ${delay.inMinutes} minutes');
      
      // Create a timer for the scheduled time
      _scheduledTimers[taskId] = Timer(delay, () {
        // Only show the alert if we haven't shown it yet
        if (!_shownAlerts.containsKey(taskId) || !_shownAlerts[taskId]!) {
          _shownAlerts[taskId] = true;
          // Show full screen alert
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => FullScreenAlertPage(
                title: title,
                body: additionalInfo ?? title,
                taskType: taskType,
                taskId: taskId,
              ),
            ),
          );
        }
      });

      print('Successfully scheduled alert for $title at ${scheduledTime.toString()}');
    } catch (e) {
      print('Error scheduling alert: $e');
    }
  }

  void cancelAlert(String taskId) {
    _scheduledTimers[taskId]?.cancel();
    _scheduledTimers.remove(taskId);
    _shownAlerts.remove(taskId);
  }

  void cancelAllAlerts() {
    for (var timer in _scheduledTimers.values) {
      timer.cancel();
    }
    _scheduledTimers.clear();
    _shownAlerts.clear();
  }
} 