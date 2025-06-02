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
  int _durationMinutes = 2;

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
    const Color primaryBlue = Color(0xFF368FF5);
    const TextStyle labelStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Quick Breathing'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xADFBE7F5),
              Color(0xFFE6F0FF),
              Color(0xFFA2CDFF),
            ],
            stops: [0.0, 0.5, 0.95],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Date:', style: labelStyle),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Choose Date'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(fontSize: 18, color: primaryBlue),
                  ),
                ),

                const SizedBox(height: 20),
                Text('Select Time:', style: labelStyle),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    _selectedTime == null
                        ? 'Choose Time'
                        : _selectedTime!.format(context),
                    style: TextStyle(fontSize: 18, color: primaryBlue),
                  ),
                ),

                const SizedBox(height: 20),
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
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 20),
                Text('Duration (minutes):', style: labelStyle),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [1, 2, 3].map((min) {
                    final selected = _durationMinutes == min;
                    return ElevatedButton(
                      onPressed: () => setState(() => _durationMinutes = min),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected ? primaryBlue : Colors.white.withOpacity(0.7),
                        minimumSize: const Size(80, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: primaryBlue),
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
                      backgroundColor: primaryBlue,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
        ),
      ),
    );
  }
}
