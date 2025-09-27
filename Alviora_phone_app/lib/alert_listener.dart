import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:just_audio/just_audio.dart';
import 'global_navigator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'emergency.dart';
import '360_view.dart';

class AlertListener extends StatefulWidget {
  final Widget child;
  const AlertListener({required this.child, Key? key}) : super(key: key);

  @override
  State<AlertListener> createState() => _AlertListenerState();
}

class _AlertListenerState extends State<AlertListener> {
  final _dbRef = FirebaseDatabase.instance.ref("alerts");
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Request notification permission on app start (especially important for iOS)
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    _dbRef.onChildAdded.listen((event) async {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final alertKey = event.snapshot.key;
      if (data["action_required"] == true && data["status"] == "active") {
        _showAlert(data, alertKey);
      }
    });
  }

  void _resolveAlert(String? alertKey) {
    if (alertKey != null) {
      _dbRef.child(alertKey).update({"status": "resolved"});
    }
  }

  void _deactivateAlert(String? alertKey) {
    if (alertKey != null) {
      _dbRef.child(alertKey).update({"action_required": false});
    }
  }

  void _showAlert(Map<String, dynamic> data, String? alertKey) async {
    final context = navigatorKey.currentState?.overlay?.context;
    if (context == null) return;

    AudioPlayer player = AudioPlayer();

    // Fire & forget audio playing (no await on play)
    try {
      await player.setAsset('assets/sounds/1.mp3');
      player.play();  // Don't await here
    } catch (e) {
      print("Sound error: $e");
      player.dispose();
    }

    // Immediately send notification and show dialog
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'alerts_channel',
        title: '⚠️ ${data["title"] ?? 'Alert'}',
        body: data["message"] ?? '',
        notificationLayout: NotificationLayout.Default,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(data["title"] ?? "Alert"),
        content: Text(data["message"] ?? "No message"),
        actions: [
          if (data["actions"]?["call_emergency"] == true)
            TextButton(
              onPressed: () async {
                player.stop();
                Navigator.of(context).pop();
                _deactivateAlert(alertKey);
                _resolveAlert(alertKey);
                navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const EmergencyPage()));
              },
              child: Text("Call ${data["emergency_number"] ?? 'Emergency'}"),
            ),
          if (data["actions"]?["view_360"] == true)
            TextButton(
              onPressed: () {
                player.stop();
                Navigator.of(context).pop();
                _deactivateAlert(alertKey);
                _resolveAlert(alertKey);
                navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const LiveViewScreen()));
              },
              child: const Text("360 View"),
            ),
          if (data["actions"]?["dismiss"] == true)
            TextButton(
              onPressed: () {
                player.stop();
                Navigator.of(context).pop();
                _deactivateAlert(alertKey);
                // Do not resolve, keep as active
              },
              child: const Text("Dismiss"),
            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) => widget.child;
}
