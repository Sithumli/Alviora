import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addschedule.dart';
import 'home_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedulesForDate(selectedDate);
  }

  Future<void> _loadSchedulesForDate(DateTime date) async {
    final dateStr = _formatDate(date);
    print("Loading schedules for date: $dateStr"); // Debug print

    try {
      final snapshot = await _firestore
          .collection('schedules')
          .where('date', isEqualTo: dateStr)
          .orderBy('time')
          .get();

      print("Found ${snapshot.docs.length} schedules"); // Debug print

      setState(() {
        _schedules = snapshot.docs.map((doc) {
          final data = doc.data();
          print("Schedule data: $data"); // Debug print
          return {
            'date': data['date'],
            'time': data['time'],
            'from': data['from'],
            'to': data['to'],
            'hasEvent': true,
            'description': data['description'] ?? 'No description',
            'docId': doc.id,
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading schedules: $e"); // Debug print
    }
  }

  String _formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  Widget _buildTopIcons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          child: const Icon(Icons.home_rounded),
        ),
        const Icon(Icons.menu),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3F86F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Your Tasks are almost accomplished!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: const [
              Icon(Icons.speed, color: Colors.white, size: 30),
              Text("72%",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final List<DateTime> weekDates = List.generate(
      7,
          (i) => now.subtract(Duration(days: now.weekday - 1 - i)),
    );

    return SizedBox(
      height: 73,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: weekDates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final date = weekDates[index];
            final isSelected = date.day == selectedDate.day &&
                date.month == selectedDate.month &&
                date.year == selectedDate.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                });
                _loadSchedulesForDate(selectedDate);
              },
              child: Container(
                width: 53,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3F86F4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${date.day}",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _weekdayLabel(date.weekday),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[weekday - 1];
  }

  Widget _buildTimeBlock({
    required bool hasEvent,
    required String description,
    required String from,
    required String to,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              from,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6FB7FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$from - $to',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundColor: Colors.red),
                      SizedBox(width: 5),
                      CircleAvatar(radius: 10, backgroundColor: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Reminder", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text("Don't forget schedule for tomorrow",
            style: TextStyle(color: Colors.blue)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF3F86F4)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_month, color: Color(0xFF3F86F4)),
              SizedBox(width: 10),
              Expanded(
                child: Text("Stress Relaxation",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text("12:00 - 16:00", style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddScheduleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F86F4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSchedule()),
          );

          if (result != null && result is Map<String, dynamic>) {
            await _firestore.collection('schedules').add({
              'date': result['date'],
              'time': result['time'],
              'from': result['from'],
              'to': result['to'],
              'description': result['description'],
              'createdAt': FieldValue.serverTimestamp(),
              'hasEvent': true,
            });

            _loadSchedulesForDate(selectedDate);
          }
        },
        child: const Text("Add Schedule",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopIcons(context),
              const SizedBox(height: 20),
              _buildProgressCard(),
              const SizedBox(height: 20),
              _buildDateSelector(),
              const SizedBox(height: 10),
              const Text(
                "Schedule Today",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _schedules.isEmpty
                    ? const Center(
                  child: Text(
                    'No schedules for today',
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ListView(
                  children: [
                    for (var sched in _schedules)
                      _buildTimeBlock(
                        hasEvent: sched['hasEvent'] ?? false,
                        description: sched['description'] ?? 'No description',
                        from: sched['from'] ?? '--:--',
                        to: sched['to'] ?? '--:--',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildReminderCard(),
              const SizedBox(height: 10),
              _buildAddScheduleButton(context),
            ],
          ),
        ),
      ),
    );
  }
}