import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'medication_schedule.dart';
import 'package:firebase_database/firebase_database.dart';
import 'more_health_alerts.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.menu, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopCard(Icons.local_drink, "Daily Water Intake", "4 Cups", true),
                  _buildTopCard(Icons.mood, "Mood", "Good", false),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLiveTemperatureCard(),
                  _buildSleepCard(),
                ],
              ),
              const SizedBox(height: 12),
              _buildExerciseCard(),
              const SizedBox(height: 20),

              _buildSectionTitle("Recent Health Alerts"),
              const SizedBox(height: 10),
              _buildAlertTile("Slight coughing detected", "Yesterday, 10:30 PM"),
              _buildAlertTile("Lower activity than usual", "2 days ago"),
              const SizedBox(height: 20),

              _buildSectionTitle(
                "Medication Tracker",
                onAdd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MedicationTrackerPage()),
                  );
                },
              ),
              const SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('medications')
                    .orderBy('datetime')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No medications found.");
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      if (data == null) return const SizedBox();

                      try {
                        final String name = data['title'] ?? 'Unnamed Medicine';
                        final DateTime dateTime = DateTime.parse(data['datetime']);
                        final String time = TimeOfDay.fromDateTime(dateTime).format(context);
                        final bool taken = data['status'] == 'Taken';

                        return _buildMedicationTile(
                          name,
                          time,
                          taken,
                          onDelete: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('medications')
                                  .doc(doc.id)
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Medication deleted')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Delete failed: $e')),
                              );
                            }
                          },
                        );
                      } catch (e) {
                        return const SizedBox();
                      }
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),
              _buildMoreAlertsButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreAlertsButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6785F2), Color(0xFFADC8FF)],
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MoreHealthAlertsScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "More Health Alerts",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTopCard(IconData icon, String title, String value, bool hasAdd) {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const Spacer(),
                if (hasAdd) const Icon(Icons.add, size: 18, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard() {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.nightlight_round, color: Colors.blue),
            SizedBox(height: 8),
            Text("Sleep Time", style: TextStyle(fontSize: 12)),
            Text("7H 25Min", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard() {
    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Exercise", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("30 minutes\n350 Cals", style: TextStyle(fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.add, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: onAdd,
          ),
      ],
    );
  }

  Widget _buildAlertTile(String message, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMedicationTile(String name, String time, bool taken, {required VoidCallback onDelete}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: taken ? const Color(0xFFDAE9FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.medical_services, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLiveTemperatureCard() {
    final dhtRef = FirebaseDatabase.instance.ref().child('dht22_sensor');

    return Expanded(
      child: StreamBuilder<DatabaseEvent>(
        stream: dhtRef.orderByKey().limitToLast(1).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingCard();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildTopCard(Icons.thermostat, "Temperature", "N/A", false);
          }

          final dataMap = snapshot.data!.snapshot.value as Map?;
          if (dataMap == null || dataMap.isEmpty) {
            return _buildTopCard(Icons.thermostat, "Temperature", "N/A", false);
          }

          final latest = dataMap.values.last;
          final temperature = latest['temperature_c']?.toStringAsFixed(1) ?? 'N/A';

          return _buildTopCard(Icons.thermostat, "Temperature", "$temperature℃", false);
        },
      ),
    );
  }

  Widget _loadingCard() {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
