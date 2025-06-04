import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSchedule extends StatefulWidget {
  const AddSchedule({super.key});

  @override
  State<AddSchedule> createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  int selectedDateIndex = 0;
  int? selectedFromTimeIndex = 24; // Default to 12:00
  int? selectedToTimeIndex = 28; // Default to 14:00
  final noteController = TextEditingController();

  late List<DateTime> weekDates;
  final List<String> timeSlots = List.generate(48, (index) {
    final hour = index ~/ 2;
    final minute = (index % 2) * 30;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  });

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = weekDates[selectedDateIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's set the schedule easily"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select the date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 73,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length + 1, // +1 for calendar box
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index < weekDates.length) {
                    final date = weekDates[index];
                    final isSelected = selectedDateIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDateIndex = index),
                      child: Container(
                        width: 53,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3F86F4)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3F86F4)
                                  : Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${date.day}",
                                style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            Text(_weekdayLabel(date.weekday),
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black54,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Calendar picker box
                    return GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: weekDates[selectedDateIndex],
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            bool exists =
                            weekDates.any((d) => isSameDate(d, picked));
                            if (!exists) {
                              weekDates.add(picked);
                              weekDates.sort((a, b) => a.compareTo(b));
                            }
                            selectedDateIndex = weekDates
                                .indexWhere((d) => isSameDate(d, picked));
                          });
                        }
                      },
                      child: Container(
                        width: 53,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.calendar_today,
                                size: 28, color: Colors.black54),
                            SizedBox(height: 4),
                            Text('More',
                                style:
                                TextStyle(color: Colors.black54, fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            const Divider(thickness: 1, height: 40),
            const Text('Select time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeDropdown("From", selectedFromTimeIndex, (val) {
                    setState(() {
                      selectedFromTimeIndex = val;
                      if (selectedToTimeIndex != null &&
                          val! >= selectedToTimeIndex!) {
                        selectedToTimeIndex =
                        val + 1 < timeSlots.length ? val + 1 : val;
                      }
                    });
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeDropdown("To", selectedToTimeIndex, (val) {
                    setState(() {
                      selectedToTimeIndex = val;
                      if (selectedFromTimeIndex != null &&
                          val! <= selectedFromTimeIndex!) {
                        selectedFromTimeIndex =
                        val - 1 >= 0 ? val - 1 : val;
                      }
                    });
                  }),
                ),
              ],
            ),

            const Divider(thickness: 1, height: 40),
            const Text('Note',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add a note',
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F86F4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (selectedFromTimeIndex == null ||
                      selectedToTimeIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please select valid time slots")),
                    );
                    return;
                  }

                  final newSchedule = {
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'time': timeSlots[selectedFromTimeIndex!],
                    'from': timeSlots[selectedFromTimeIndex!],
                    'to': timeSlots[selectedToTimeIndex!],
                    'description': noteController.text.trim().isEmpty
                        ? 'No note'
                        : noteController.text.trim(),
                    'hasEvent': true,
                  };

                  Navigator.pop(context, newSchedule);
                },
                child:
                const Text('Save Schedule', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDropdown(
      String label, int? selectedIndex, ValueChanged<int?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedIndex,
          items: timeSlots.asMap().entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[weekday - 1];
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}