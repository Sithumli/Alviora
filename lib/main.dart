import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/robot_face_screen.dart';
import 'FullScreenAlertPage.dart';
import 'services/notification_service.dart';
import 'services/task_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final notificationService = NotificationService();
final taskService = TaskService();

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  final payload = receivedAction.payload;
  final taskType = payload?['taskType'] ?? 'default';
  
  // Show full screen alert immediately
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => FullScreenAlertPage(
        title: receivedAction.title ?? '',
        body: receivedAction.body ?? '',
        taskType: taskType,
        taskId: payload?['taskId'],
      ),
    ),
  );
}

Future<void> initializeNotifications() async {
  await AwesomeNotifications().initialize(
    null, // null means use default app icon
    [
      NotificationChannel(
        channelKey: 'task_alerts',
        channelName: 'Task Alerts',
        channelDescription: 'Notifications for scheduled tasks',
        playSound: true,
        importance: NotificationImportance.High,
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        enableVibration: true,
        enableLights: true,
        criticalAlerts: true,
      ),
    ],
    debug: true,
  );

  // Request notification permissions
  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  // Set up notification listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (receivedAction) async {
      final payload = receivedAction.payload;
      final taskType = payload?['taskType'] ?? 'default';
      
      // Show full screen alert immediately
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => FullScreenAlertPage(
            title: receivedAction.title ?? '',
            body: receivedAction.body ?? '',
            taskType: taskType,
            taskId: payload?['taskId'],
          ),
        ),
      );
    },
    onNotificationCreatedMethod: (receivedNotification) async {
      print('Notification created: ${receivedNotification.title}');
      // Don't show full screen alert here
    },
    onNotificationDisplayedMethod: (receivedNotification) async {
      print('Notification displayed: ${receivedNotification.title}');
      // Only show full screen alert if this is a scheduled notification
      if (receivedNotification.payload?['taskType'] != null) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => FullScreenAlertPage(
                title: receivedNotification.title ?? '',
                body: receivedNotification.body ?? '',
                taskType: receivedNotification.payload?['taskType'] ?? 'default',
                taskId: receivedNotification.payload?['taskId'],
              ),
            ),
          );
        } else {
          print('Navigator key is not available, cannot show full screen alert');
        }
      }
    },
    onDismissActionReceivedMethod: (receivedAction) async {
      print('Notification dismissed: ${receivedAction.title}');
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize notifications
  await initializeNotifications();

  // Initialize task service
  taskService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alviora Tablet',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const RobotFaceScreen(),
    );
  }
}