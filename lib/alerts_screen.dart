import 'package:flutter/material.dart';

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

  List<Widget> buildAlertList() {
    return [
      buildAlertCard(
        icon: Icons.warning,
        title: "Fall Detected",
        description: "Possible Fall Detected in Living Room",
        tag: "Critical",
        time: "10:23 AM",
        date: "May 2",
        tagColor: Colors.red,
      ),
      buildAlertCard(
        icon: Icons.thermostat,
        title: "Elevated Temperature",
        description: "Body Temperature Reading Above Normal",
        tag: "Warning",
        time: "09:15 AM",
        date: "May 2",
        tagColor: Colors.orange,
      ),
      buildAlertCard(
        icon: Icons.medication,
        title: "Missed Medication",
        description: "Blood Pressure Medication Not Taken",
        tag: "Warning",
        time: "08:00 AM",
        date: "May 2",
        tagColor: Colors.orange,
      ),
      buildAlertCard(
        icon: Icons.air,
        title: "Poor Air Quality",
        description: "Air Quality Below Recommended Levels",
        tag: "Warning",
        time: "07:50 AM",
        date: "May 2",
        tagColor: Colors.orange,
      ),
      buildAlertCard(
        icon: Icons.directions_walk,
        title: "Low Activity Level",
        description: "Reduced Movement Detected Today",
        tag: "Info",
        time: "06:45 AM",
        date: "May 2",
        tagColor: Colors.blue,
      ),
      buildAlertCard(
        icon: Icons.sick,
        title: "Coughing Detected",
        description: "Frequent Coughing Episodes Overnight",
        tag: "Warning",
        time: "11:40 PM",
        date: "May 1",
        tagColor: Colors.orange,
      ),
      buildAlertCard(
        icon: Icons.battery_alert,
        title: "Low Battery",
        description: "Alviora Robot Battery at 10%",
        tag: "Info",
        time: "10:30 PM",
        date: "May 1",
        tagColor: Colors.blue,
      ),
      buildAlertCard(
        icon: Icons.mood_bad,
        title: "Mood Change Detected",
        description: "Signs of Potential Distress Observed",
        tag: "Warning",
        time: "08:15 PM",
        date: "May 1",
        tagColor: Colors.orange,
      ),
    ];
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
            Tab(text: "Critical"),
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
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(children: buildAlertList()),
                Center(child: Text("No critical alerts")),
                Center(child: Text("No resolved alerts")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
