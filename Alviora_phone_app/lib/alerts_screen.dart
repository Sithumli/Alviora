import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Alert {
  final String type;
  final String timestamp;
  final Map<String, dynamic> details;
  final String status;
  final String severity;
  final bool actionRequired;
  final Map<String, dynamic> actions;
  final String emergencyNumber;
  final String title;
  final String message;
  final String sound;

  Alert({
    required this.type,
    required this.timestamp,
    required this.details,
    required this.status,
    required this.severity,
    required this.actionRequired,
    required this.actions,
    required this.emergencyNumber,
    required this.title,
    required this.message,
    required this.sound,
  });

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      type: map['type'] ?? '',
      timestamp: map['timestamp'] ?? '',
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      status: map['status'] ?? '',
      severity: map['severity'] ?? '',
      actionRequired: map['action_required'] ?? false,
      actions: Map<String, dynamic>.from(map['actions'] ?? {}),
      emergencyNumber: map['emergency_number'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      sound: map['sound'] ?? '',
    );
  }
}

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedToggle = 0; // 0: Reminders, 1: System

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<Alert> filterAlerts(List<Alert> alerts, String status) {
    return alerts.where((a) => a.status.toLowerCase() == status.toLowerCase()).toList();
  }

  List<Widget> buildAlertList(List<Alert> alerts) {
    if (alerts.isEmpty) {
      return [Center(child: Text('No alerts found'))];
    }
    return alerts.map((alert) {
      Color tagColor;
      IconData icon;
      switch (alert.type) {
        case 'fall':
          icon = Icons.warning;
          tagColor = Colors.red;
          break;
        case 'cough':
          icon = Icons.sick;
          tagColor = Colors.orange;
          break;
        case 'gas_leak':
          icon = Icons.air;
          tagColor = Colors.orange;
          break;
        case 'environmental':
          icon = Icons.thermostat;
          tagColor = Colors.orange;
          break;
        case 'no_movement':
          icon = Icons.directions_walk;
          tagColor = Colors.blue;
          break;
        default:
          icon = Icons.info;
          tagColor = Colors.blue;
      }
      // Parse date and time
      DateTime? dt;
      try {
        dt = DateTime.parse(alert.timestamp);
      } catch (_) {}
      String date = dt != null ? "${dt.month}/${dt.day}" : "";
      String time = dt != null ? "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}" : "";
      return buildAlertCard(
        icon: icon,
        title: alert.title,
        description: alert.message,
        tag: alert.severity,
        time: time,
        date: date,
        tagColor: tagColor,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alviora Alert System", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(text: "Active"),
            Tab(text: "Resolved"),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          buildToggleButtons(),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseDatabase.instance.ref('alerts').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return Center(child: Text('No alerts found'));
                }
                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Alert> allAlerts = data.values
                  .map((v) => Alert.fromMap(Map<String, dynamic>.from(v)))
                  .toList()
                  .reversed
                  .toList();
                return TabBarView(
                  controller: _tabController,
                  children: [
                    ListView(children: buildAlertList(filterAlerts(allAlerts, 'active'))),
                    ListView(children: buildAlertList(filterAlerts(allAlerts, 'critical'))),
                    ListView(children: buildAlertList(filterAlerts(allAlerts, 'resolved'))),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildToggle("Reminders", 0),
        buildToggle("System", 1),
      ],
    );
  }

  Widget buildToggle(String text, int index) {
    bool isSelected = selectedToggle == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedToggle = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildAlertCard({
    required IconData icon,
    required String title,
    required String description,
    required String tag,
    required String time,
    required String date,
    required Color tagColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: tagColor, size: 30),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              SizedBox(width: 8),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
      trailing: Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
      isThreeLine: true,
    );
  }
}
