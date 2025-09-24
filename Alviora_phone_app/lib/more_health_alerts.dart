import 'package:flutter/material.dart';

class MoreHealthAlertsScreen extends StatefulWidget {
  const MoreHealthAlertsScreen({Key? key}) : super(key: key);

  @override
  State<MoreHealthAlertsScreen> createState() => _MoreHealthAlertsScreenState();
}

class _MoreHealthAlertsScreenState extends State<MoreHealthAlertsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final List<Map<String, String>> _alerts = [
    {'message': 'Heart rate increased briefly', 'time': 'Today, 3:30 PM'},
    {'message': 'Temperature slightly above normal', 'time': 'Today, 2:00 PM'},
    {'message': 'Low activity detected', 'time': 'Yesterday, 9:45 AM'},
    {'message': 'Missed medication alert', 'time': '2 days ago'},
    {'message': 'Unusual sleep pattern', 'time': '3 days ago'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedAlertCard(String message, String time, int index) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.0, 0.2 * (index + 1)),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut))),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.blue),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0FA),
      appBar: AppBar(
        title: const Text('More Health Alerts', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          return _buildAnimatedAlertCard(_alerts[index]['message']!, _alerts[index]['time']!, index);
        },
      ),
    );
  }
}
