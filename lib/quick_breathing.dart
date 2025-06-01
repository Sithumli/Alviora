import 'package:flutter/material.dart';

class GrannyScheduleQuickBreathingPage extends StatefulWidget {
  const GrannyScheduleQuickBreathingPage({Key? key}) : super(key: key);

  @override
  State<GrannyScheduleQuickBreathingPage> createState() => _GrannyScheduleQuickBreathingPageState();
}

class _GrannyScheduleQuickBreathingPageState extends State<GrannyScheduleQuickBreathingPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _recurrence = 'None';
  int _durationMinutes = 2; // Quick breathing sessions are shorter

  final List<String> recurrenceOptions = ['None', 'Daily', 'Weekly'];

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now().add(const Duration(minutes: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? initialDate,
      firstDate: initialDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveSchedule() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Schedule Saved'),
        content: Text(
          'Quick breathing session scheduled for\n${scheduledDateTime.toLocal()} \nDuration: $_durationMinutes minutes\nRecurrence: $_recurrence',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Quick Breathing'),
        backgroundColor: Colors.indigo[700],
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date:', style: labelStyle),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickDate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.indigo),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                _selectedDate == null
                    ? 'Choose Date'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: const TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),

            const SizedBox(height: 24),

            Text('Select Time:', style: labelStyle),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.indigo),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                _selectedTime == null
                    ? 'Choose Time'
                    : _selectedTime!.format(context),
                style: const TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),

            const SizedBox(height: 24),

            Text('Recurrence:', style: labelStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _recurrence,
              items: recurrenceOptions
                  .map((option) => DropdownMenuItem(
                value: option,
                child: Text(option, style: const TextStyle(fontSize: 18)),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _recurrence = val;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),

            const SizedBox(height: 24),

            Text('Duration (minutes):', style: labelStyle),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [1, 2, 3].map((min) {
                final selected = _durationMinutes == min;
                return ElevatedButton(
                  onPressed: () => setState(() => _durationMinutes = min),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected ? Colors.indigo : Colors.grey[300],
                    minimumSize: const Size(80, 50),
                  ),
                  child: Text(
                    '$min',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            Center(
              child: ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Save Schedule',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
