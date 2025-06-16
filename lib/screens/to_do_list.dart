import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> fetchedTasks = [];

    try {
      // --- Normal Schedules ---
      // Firestore requires a composite index for where + orderBy on different fields
      final normalSnapshot = await firestore
          .collection('schedules')
          .where('date', isEqualTo: formattedDate)
      // If 'from' is a string or timestamp, ensure proper ordering or create index.
          .orderBy('from')
          .get();

      fetchedTasks.addAll(normalSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'icon': Icons.event_note,
          'title': data['description'] ?? 'No Description',
          'status': data['hasEvent'] == true ? 'Scheduled' : 'Not Scheduled',
          'time': "${data['from']} - ${data['to']}",
          'details': [
            "From: ${data['from'] ?? 'N/A'}",
            "To: ${data['to'] ?? 'N/A'}",
            "Created at: ${data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate().toLocal().toString().substring(0, 16) : 'N/A'}",
          ],
        };
      }));

      // --- Quick Breathing ---
      final startOfDay = DateTime(today.year, today.month, today.day);
      final startOfNextDay = startOfDay.add(const Duration(days: 1));

      final quickSnapshot = await firestore
          .collection('quick_breathing_schedules')
          .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDateTime', isLessThan: Timestamp.fromDate(startOfNextDay))
          .get();

      fetchedTasks.addAll(quickSnapshot.docs.map((doc) {
        final data = doc.data();
        final scheduledTimestamp = data['scheduledDateTime'] as Timestamp?;
        final scheduledDateTime = scheduledTimestamp?.toDate().toLocal();

        return {
          'icon': Icons.air,
          'title': "Quick Breathing (${data['durationMinutes'] ?? 0} min)",
          'status': data['recurrence'] ?? 'One-time',
          'time': scheduledDateTime != null
              ? scheduledDateTime.toString().substring(11, 16)
              : 'N/A',
          'details': [
            "Duration: ${data['durationMinutes'] ?? 'N/A'} minutes",
            "Recurrence: ${data['recurrence'] ?? 'N/A'}",
            "Scheduled: ${scheduledDateTime?.toString().substring(0, 16) ?? 'N/A'}",
          ],
        };
      }));

      // --- Deep Breathing ---
      final deepSnapshot = await firestore
          .collection('deep_breathing_schedules')
          .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDateTime', isLessThan: Timestamp.fromDate(startOfNextDay))
          .get();

      fetchedTasks.addAll(deepSnapshot.docs.map((doc) {
        final data = doc.data();
        final scheduledTimestamp = data['scheduledDateTime'] as Timestamp?;
        final scheduledDateTime = scheduledTimestamp?.toDate().toLocal();

        return {
          'icon': Icons.spa,
          'title': "Deep Breathing (${data['durationMinutes'] ?? 0} min)",
          'status': data['recurrence'] ?? 'One-time',
          'time': scheduledDateTime != null
              ? scheduledDateTime.toString().substring(11, 16)
              : 'N/A',
          'details': [
            "Duration: ${data['durationMinutes'] ?? 'N/A'} minutes",
            "Recurrence: ${data['recurrence'] ?? 'N/A'}",
            "Scheduled: ${scheduledDateTime?.toString().substring(0, 16) ?? 'N/A'}",
          ],
        };
      }));

      // --- Water Intake Reminder ---
      final waterDoc = await firestore
          .collection('health_alerts')
          .doc('9C49NtsHl0TajBKTDzEIoSV4oNZ2')
          .get();

      if (waterDoc.exists) {
        final data = waterDoc.data()!;
        final cups = data['dailyWaterIntake'] ?? 0;
        if (cups > 0) {
          final startHour = 8;
          final endHour = 20;
          final interval = ((endHour - startHour) * 60) ~/ cups;

          for (int i = 0; i < cups; i++) {
            final scheduled = DateTime(today.year, today.month, today.day, startHour)
                .add(Duration(minutes: i * interval));
            fetchedTasks.add({
              'icon': Icons.local_drink,
              'title': "Drink Water (Cup ${i + 1}/$cups)",
              'status': 'Hydration',
              'time':
              "${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}",
              'details': [
                "Auto spaced based on $cups cups",
                "Hydration scheduled at ${scheduled.toLocal().toString().substring(0, 16)}",
              ],
            });
          }
        }
      }
    } catch (e) {
      // You can log errors here
      print('Error fetching tasks: $e');
    }

    setState(() {
      tasks = fetchedTasks;
      isLoading = false;
    });
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
                    child: Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  status,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              children: details
                  .map((detail) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                title: Row(
                  children: [
                    Icon(Icons.brightness_1, size: 10, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
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
                        style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: "L I S T",
                        style: TextStyle(letterSpacing: 8, color: Colors.blueAccent, fontSize: 18),
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
