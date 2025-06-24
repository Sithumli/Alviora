import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';
import 'medication_schedule.dart';
import 'more_health_alerts.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('health_alerts')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        int cups = 0;
                        if (snapshot.hasData && snapshot.data!.exists) {
                          cups = snapshot.data!['dailyWaterIntake'] ?? 0;
                        }
                        return _buildTopCard(
                          Icons.local_drink,
                          "Daily Water Intake",
                          "$cups Cups",
                          true,
                          onAdd: () => _showWaterIntakeBottomSheet(context),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<DatabaseEvent>(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child('emotion_status')
                          .onValue,
                      builder: (context, snapshot) {
                        String emotion = '...';
                        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
                          if (data != null && data['emotion'] != null) {
                            emotion = data['emotion'].toString();
                          } else {
                            emotion = 'Unknown';
                          }
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          emotion = '...';
                        } else {
                          emotion = 'Unknown';
                        }
                        return _buildTopCard(
                          Icons.mood,
                          "Mood",
                          emotion,
                          false,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildLiveTemperatureCard()),
                  Expanded(child: _buildSleepCard()),
                ],
              ),
              const SizedBox(height: 12),
              _buildExerciseCard(),
              const SizedBox(height: 20),

              _buildSectionTitle("Recent Health Alerts"),
              const SizedBox(height: 10),
              // Water progress alert
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('water_progress')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .where('date', isEqualTo: DateTime.now().toIso8601String().substring(0, 10))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  if (snapshot.hasError) {
                    return const SizedBox();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }
                  final doc = snapshot.data!.docs.first;
                  final data = doc.data() as Map<String, dynamic>;
                  final int completedCups = data['completedCups'] ?? 0;
                  final int totalCups = data['totalCups'] ?? 0;
                  final String date = data['date'] ?? '';
                  return _buildWaterAlertTile(
                    "Water Progress: $completedCups out of $totalCups cups completed",
                    date,
                  );
                },
              ),
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
                    .where('datetime', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String())
                    .where('datetime', isLessThan: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1).toIso8601String())
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
                    return const Text("No medications for today.");
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      if (data == null) return const SizedBox();

                      try {
                        final String name = data['title'] ?? 'Unnamed Medicine';
                        final DateTime dateTime = DateTime.parse(data['datetime']);
                        final String time = TimeOfDay.fromDateTime(dateTime).format(context);
                        final String status = data['status'] ?? 'Upcoming';
                        IconData icon;
                        Color iconColor;
                        if (status == 'Completed') {
                          icon = Icons.check_circle;
                          iconColor = Colors.green;
                        } else if (status == 'Skipped') {
                          icon = Icons.cancel;
                          iconColor = Colors.red;
                        } else {
                          icon = Icons.access_time;
                          iconColor = Colors.amber;
                        }

                        return _buildMedicationTile(
                          name,
                          time,
                          status,
                          icon: icon,
                          iconColor: iconColor,
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

  void _showWaterIntakeBottomSheet(BuildContext context) {
    double selectedCups = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Select water cups",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Lottie.asset(
                    'assets/water_glass.json',
                    height: 120,
                    repeat: true,
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    min: 0,
                    max: 12,
                    divisions: 12,
                    label: '${selectedCups.toInt()} cups',
                    value: selectedCups,
                    onChanged: (double value) {
                      setState(() {
                        selectedCups = value;
                      });
                    },
                    activeColor: const Color(0xFF6785F2),
                    inactiveColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${selectedCups.toInt()} cups",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6785F2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '"Keep sipping — your body will thank you!"',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6785F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('health_alerts')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .set({
                          'dailyWaterIntake': selectedCups.toInt(),
                          'timestamp': Timestamp.now(),
                        }, SetOptions(merge: true));
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.water_drop, color: Colors.white),
                    label: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  Widget _buildTopCard(IconData icon, String title, String value, bool hasAdd, {VoidCallback? onAdd}) {
    return Container(
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
              if (hasAdd) 
                GestureDetector(
                  onTap: onAdd,
                  child: const Icon(Icons.add, size: 18, color: Colors.blue),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSleepCard() {
    return Container(
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

  Widget _buildMedicationTile(String name, String time, String status, {required IconData icon, required Color iconColor, required VoidCallback onDelete}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: status == 'Completed' ? const Color(0xFFDAE9FF) : Colors.white,
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
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const Spacer(),
          Text(status, style: TextStyle(fontSize: 12, color: iconColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLiveTemperatureCard() {
    final dhtRef = FirebaseDatabase.instance.ref().child('dht22_sensor');
    return StreamBuilder<DatabaseEvent>(
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

  Widget _buildWaterAlertTile(String message, String time) {
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
          const Icon(Icons.local_drink, color: Colors.blue),
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
}