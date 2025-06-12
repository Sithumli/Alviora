import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool _isScheduling = false; // to disable button when processing

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
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF368FF5),
            onPrimary: Colors.white,
            onSurface: Color(0xFF368FF5),
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
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF368FF5),
            onPrimary: Colors.white,
            onSurface: Color(0xFF368FF5),
          ),
          timePickerTheme: const TimePickerThemeData(
            dialHandColor: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _scheduleSession() async {
    if (_selectedDate == null || _selectedTime == null || _selectedMeditation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date, time, and meditation type')),
      );
      return;
    }

    setState(() => _isScheduling = true);

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      // Store session in Firestore
      await FirebaseFirestore.instance.collection('meditation_sessions').add({
        'meditationType': _selectedMeditation,
        'scheduledDateTime': scheduledDateTime.toUtc(), // always store in UTC
        'frequency': _selectedFrequency,
        'createdAt': DateTime.now().toUtc(),
      });

      setState(() => _isScheduling = false);

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

      // Optional: reset selections or keep them as is
      // setState(() {
      //   _selectedDate = null;
      //   _selectedTime = null;
      //   _selectedMeditation = null;
      //   _selectedFrequency = 'Once';
      // });

    } catch (e) {
      setState(() => _isScheduling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule session: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Schedule Meditation'),
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFBE7F5),
                  Color(0xFFE6F0FF),
                  Color(0xFFA2CDFF),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    'Set a time for a calm breathing session for your loved one.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildCardTile(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    subtitle: _formattedDate,
                    onTap: _pickDate,
                  ),

                  const SizedBox(height: 16),

                  _buildCardTile(
                    icon: Icons.access_time,
                    title: 'Time',
                    subtitle: _formattedTime,
                    onTap: _pickTime,
                  ),

                  const SizedBox(height: 16),

                  _buildDropdownCard(
                    label: 'Select Meditation Type',
                    value: _selectedMeditation,
                    items: meditationTypes,
                    onChanged: (val) => setState(() => _selectedMeditation = val),
                  ),

                  const SizedBox(height: 16),

                  _buildDropdownCard(
                    label: 'Select Frequency',
                    value: _selectedFrequency,
                    items: frequencies,
                    onChanged: (val) => setState(() => _selectedFrequency = val!),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isScheduling ? null : _scheduleSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isScheduling ? Colors.grey : Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isScheduling
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Schedule Session',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.keyboard_arrow_down),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdownCard({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButton<String>(
          value: value,
          hint: Text(label),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          underline: const SizedBox(),
          items: items
              .map((type) => DropdownMenuItem(
            value: type,
            child: Text(type, style: const TextStyle(color: Colors.black87)),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
