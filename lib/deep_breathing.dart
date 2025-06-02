import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrannyScheduleBreathingPage extends StatefulWidget {
  const GrannyScheduleBreathingPage({Key? key}) : super(key: key);

  @override
  State<GrannyScheduleBreathingPage> createState() => _GrannyScheduleBreathingPageState();
}

class _GrannyScheduleBreathingPageState extends State<GrannyScheduleBreathingPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _recurrence = 'None';
  int _durationMinutes = 5;

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
          'Deep breathing session scheduled for\n${scheduledDateTime.toLocal()} \nDuration: $_durationMinutes minutes\nRecurrence: $_recurrence',
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Schedule Breathing',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
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
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xADFBE7F5),
                  Color(0xFFE6F0FF),
                  Color(0xFFA2CDFF),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Select Date:"),
                  _buildButton(
                    text: _selectedDate == null
                        ? "Choose Date"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Select Time:"),
                  _buildButton(
                    text: _selectedTime == null
                        ? "Choose Time"
                        : _selectedTime!.format(context),
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Recurrence:"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _recurrence,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _recurrence = value;
                          });
                        }
                      },
                      items: recurrenceOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Duration (minutes):"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [3, 5, 7].map((min) {
                      final selected = _durationMinutes == min;
                      return ElevatedButton(
                        onPressed: () => setState(() => _durationMinutes = min),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selected ? Colors.indigo : Colors.white,
                          foregroundColor: selected ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(80, 50),
                        ),
                        child: Text(
                          '$min',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Save Schedule",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        side: const BorderSide(color: Colors.blueAccent),
      ),
      child: Text(text, style: GoogleFonts.inter(fontSize: 16)),
    );
  }
}
