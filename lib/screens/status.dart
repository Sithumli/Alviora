import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  int completedCups = 0;
  int totalCups = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> todayMedications = [];
  bool isLoadingMedications = true;
  double? temperature;
  final DatabaseReference dhtRef = FirebaseDatabase.instance.ref('dht22_sensor');
  String? moodEmotion;
  final DatabaseReference moodRef = FirebaseDatabase.instance.ref('emotion_status');

  @override
  void initState() {
    super.initState();
    _loadWaterProgress();
    _loadTodayMedications();
    _loadTemperature();
    _loadMoodData();
  }

  void _loadMoodData() {
    moodRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      print('DEBUG: emotion_status snapshot value: \\${snapshot.value}');
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final emotion = data['emotion'] as String?;
        if (emotion != null) {
          if (mounted) {
            setState(() {
              moodEmotion = emotion;
            });
          }
        }
      }
    }, onError: (error) {
      // Handle error, e.g., log it
      print('Error loading mood data: $error');
    });
  }

  void _loadTemperature() {
    // Listen to DHT22 temperature updates
    dhtRef.orderByKey().limitToLast(1).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final last = snapshot.children.first.value as Map<dynamic, dynamic>;
        final tempVal = (last['temperature_c'] as num?)?.toDouble();
        if (tempVal != null) {
          setState(() {
            temperature = tempVal;
          });
        }
      }
    });
  }

  Future<void> _loadWaterProgress() async {
    try {
      final today = DateTime.now();
      final dateKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      final progressDoc = await FirebaseFirestore.instance.collection('water_progress').doc(dateKey).get();
      
      if (progressDoc.exists) {
        final data = progressDoc.data()!;
        setState(() {
          completedCups = data['completedCups'] ?? 0;
          totalCups = data['totalCups'] ?? 0;
          isLoading = false;
        });
      } else {
        // No progress for today, get total from health_alerts
        final healthDoc = await FirebaseFirestore.instance.collection('health_alerts').doc('9C49NtsHl0TajBKTDzEIoSV4oNZ2').get();
        setState(() {
          completedCups = 0;
          totalCups = healthDoc.data()?['dailyWaterIntake'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading water progress: $e');
      setState(() {
        completedCups = 0;
        totalCups = 0;
        isLoading = false;
      });
    }
  }

  Future<void> _loadTodayMedications() async {
    try {
      final today = DateTime.now();
      final dateKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      // Get today's medications from the medications collection
      final medicationsQuery = await FirebaseFirestore.instance
          .collection('medications')
          .get();
      
      final medications = <Map<String, dynamic>>[];
      
      for (final doc in medicationsQuery.docs) {
        final data = doc.data();
        final datetimeStr = data['datetime'] ?? '';
        
        // Parse the datetime string to get the date
        DateTime? medicationDate;
        try {
          medicationDate = DateTime.parse(datetimeStr);
        } catch (e) {
          print('Error parsing datetime: $e');
          continue;
        }
        
        // Check if this medication is for today
        final medicationDateKey = "${medicationDate.year}-${medicationDate.month.toString().padLeft(2, '0')}-${medicationDate.day.toString().padLeft(2, '0')}";
        if (medicationDateKey != dateKey) {
          continue; // Skip medications not for today
        }
        
        final status = data['status'] ?? 'Pending';
        final timeStr = "${medicationDate.hour.toString().padLeft(2, '0')}:${medicationDate.minute.toString().padLeft(2, '0')}";
        
        // Include all medications for today regardless of status or time
        medications.add({
          'id': doc.id,
          'title': data['title'] ?? 'Medication',
          'time': timeStr,
          'status': status,
          'description': data['lastStatus'] ?? '',
        });
      }
      
      // Sort by time
      medications.sort((a, b) => a['time'].compareTo(b['time']));
      
      setState(() {
        todayMedications = medications;
        isLoadingMedications = false;
      });
    } catch (e) {
      print('Error loading medications: $e');
      setState(() {
        todayMedications = [];
        isLoadingMedications = false;
      });
    }
  }

  String _getMedicationStatusText(String status, String time) {
    final timeStr = time.isNotEmpty ? ' - $time' : '';
    
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Taken$timeStr';
      case 'skipped':
        return 'Skipped$timeStr';
      case 'pending':
        final now = DateTime.now();
        final taskTime = _parseTime(time);
        if (taskTime != null && now.isAfter(taskTime)) {
          return 'Overdue$timeStr';
        } else {
          return 'Upcoming$timeStr';
        }
      default:
        return 'Pending$timeStr';
    }
  }

  IconData _getMedicationIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'skipped':
        return Icons.cancel;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.access_time;
    }
  }

  Color _getMedicationIconColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'skipped':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      print('Error parsing time: $e');
    }
    return null;
  }

  Widget _buildCard({required Widget child, double? height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A90E2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildWaterIntakeCard() {
    final progress = totalCups > 0 ? completedCups / totalCups : 0.0;
    final cupsToShow = totalCups > 0 ? totalCups : 8; // Default to 8 if no data

    return _buildCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Daily Water Intake',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$completedCups',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      Text(
                        '/$totalCups',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isLoading ? 'Loading...' : '$completedCups of $totalCups Cups',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isLoading && totalCups > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';

  IconData _getMoodIcon(String? emotion) {
    switch (emotion?.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'surprised':
        return Icons.sentiment_satisfied_alt;
      case 'fear':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_satisfied; // Default for 'Good' mood or null
    }
  }

  Widget _buildMoodCard() {
    return _buildCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Mood',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              _getMoodIcon(moodEmotion),
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            moodEmotion != null ? _capitalize(moodEmotion!) : 'Loading...',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return _buildCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Temperature',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Icon(
            Icons.thermostat,
            color: Color(0xFF4A90E2),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            temperature != null ? '${temperature!.toStringAsFixed(1)}°C' : 'Loading...',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard() {
    return _buildCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sleep Time',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: 0.75,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                  ),
                ),
                const Center(
                  child: Text(
                    '7H 25Min',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard() {
    return _buildCard(
      child: Row(
        children: [
          const Icon(
            Icons.directions_run,
            color: Color(0xFF4A90E2),
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exercise',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('30 minutes', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.whatshot, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('350 Cals', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAlertsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Health Alerts',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            icon: Icons.circle,
            iconColor: const Color(0xFF4A90E2),
            title: 'Slight coughing detected',
            time: 'Yesterday, 10:30 PM',
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            icon: Icons.show_chart,
            iconColor: const Color(0xFF4A90E2),
            title: 'Lower activity than usual',
            time: '2 days ago',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medication Tracker',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoadingMedications)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                ),
              ),
            )
          else if (todayMedications.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No medications scheduled for today',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...todayMedications.map((medication) {
              final statusText = _getMedicationStatusText(medication['status'], medication['time']);
              final icon = _getMedicationIcon(medication['status']);
              final iconColor = _getMedicationIconColor(medication['status']);
              
              return Column(
                children: [
                  _buildMedicationItem(
                    icon: icon,
                    iconColor: iconColor,
                    title: medication['title'],
                    subtitle: statusText,
                  ),
                  if (medication != todayMedications.last)
                    const SizedBox(height: 12),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildMedicationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Builder(
          builder: (context) {
            bool isHovered = false;
            return StatefulBuilder(
              builder: (context, setState) {
                return MouseRegion(
                  onEnter: (_) => setState(() => isHovered = true),
                  onExit: (_) => setState(() => isHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? const Color(0xFF4A90E2).withOpacity(0.1)
                          : const Color(0xFFF8FBFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHovered
                            ? const Color(0xFF4A90E2).withOpacity(0.4)
                            : const Color(0xFF4A90E2).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(isHovered ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(icon, color: iconColor, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Center(
                  child: Text(
                    'Health Dash Board',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Top row cards
                Row(
                  children: [
                    Expanded(child: _buildWaterIntakeCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMoodCard()),
                  ],
                ),
                const SizedBox(height: 12),

                // Second row cards
                Row(
                  children: [
                    Expanded(child: _buildTemperatureCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSleepCard()),
                  ],
                ),
                const SizedBox(height: 12),

                // Exercise card
                _buildExerciseCard(),
                const SizedBox(height: 12),

                // Bottom row cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildHealthAlertsCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMedicationCard()),
                  ],
                ),
                const SizedBox(height: 24),

                // Go Back button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text(
                      "Go Back",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF4A90E2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}