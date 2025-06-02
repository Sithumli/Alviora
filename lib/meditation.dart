import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeditationSchedulerPage extends StatefulWidget {
  const MeditationSchedulerPage({super.key});

  @override
  State<MeditationSchedulerPage> createState() => _MeditationSchedulerPageState();
}

class _MeditationSchedulerPageState extends State<MeditationSchedulerPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedMeditation;
  String _selectedFrequency = 'Once';

  final List<String> meditationTypes = [
    '5 min Calm Breathing',
    '10 min Body Scan',
    '15 min Deep Relax',
  ];

  final List<String> frequencies = [
    'Once',
    'Daily',
    'Weekdays',
  ];

  String get _formattedDate {
    if (_selectedDate == null) return 'Select Date';
    return DateFormat.yMMMEd().format(_selectedDate!);
  }

  String get _formattedTime {
    if (_selectedTime == null) return 'Select Time';
    final hour = _selectedTime!.hourOfPeriod.toString().padLeft(2, '0');
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF368FF5),
            onPrimary: Colors.white,
            onSurface: Color(0xFF368FF5),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF368FF5),
            onPrimary: Colors.white,
            onSurface: Color(0xFF368FF5),
          ),
          timePickerTheme: TimePickerThemeData(
            dialHandColor: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _scheduleSession() {
    if (_selectedDate == null || _selectedTime == null || _selectedMeditation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date, time, and meditation type')),
      );
      return;
    }
    // Here you can add your scheduling logic (e.g., send to backend or local notifications)
    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Session Scheduled'),
        content: Text(
          'Your meditation session "${_selectedMeditation!}" has been scheduled on '
              '${DateFormat.yMMMEd().add_jm().format(scheduledDateTime)}.\nFrequency: $_selectedFrequency',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Meditation'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Set a time for a calm breathing session for your loved one.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Date Picker
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.black87),
                title: const Text('Date'),
                subtitle: Text(_formattedDate),
                onTap: _pickDate,
                trailing: const Icon(Icons.keyboard_arrow_down),
              ),
            ),

            const SizedBox(height: 16),

            // Time Picker
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.black87),
                title: const Text('Time'),
                subtitle: Text(_formattedTime),
                onTap: _pickTime,
                trailing: const Icon(Icons.keyboard_arrow_down),
              ),
            ),

            const SizedBox(height: 16),

            // Meditation Type Dropdown
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: _selectedMeditation,
                  hint: const Text('Select Meditation Type'),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                  underline: const SizedBox(),
                  items: meditationTypes
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(color: Colors.black87)),
                  ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedMeditation = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Frequency Dropdown
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                  underline: const SizedBox(),
                  items: frequencies
                      .map((freq) => DropdownMenuItem(
                    value: freq,
                    child: Text(freq, style: const TextStyle(color: Colors.black87)),
                  ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedFrequency = val);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Schedule Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _scheduleSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Schedule Session',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
