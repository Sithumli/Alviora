import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '360 Live View Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LiveViewScreen(),
    );
  }
}

class LiveViewScreen extends StatelessWidget {
  const LiveViewScreen({super.key});

  final String streamUrl = 'http://192.168.1.5:8080/stream';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('360 Live View', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Live View", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Viewing: Bed Room", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // Live Stream Container
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: LiveStreamView(streamUrl: streamUrl),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(Icons.video_call, "Video Call"),
                _actionButton(Icons.record_voice_over, "Speak"),
                _actionButton(Icons.analytics, "Status"),
                _actionButton(Icons.settings, "Settings"),
              ],
            ),

            const SizedBox(height: 30),

            // Info Cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                InfoCard(title: "Room Temperature", value: "24°C (Normal)"),
                InfoCard(title: "Air Quality", value: "Good (97%)"),
                InfoCard(title: "Last Movement", value: "2 mins ago"),
                InfoCard(title: "Robot Battery", value: "87% (Charging)"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue.shade800, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12))
      ],
    );
  }
}

class LiveStreamView extends StatefulWidget {
  final String streamUrl;

  const LiveStreamView({super.key, required this.streamUrl});

  @override
  State<LiveStreamView> createState() => _LiveStreamViewState();
}

class _LiveStreamViewState extends State<LiveStreamView> {
  bool _streamAvailable = false;
  bool _loading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.streamUrl));
    _checkStreamAvailability();
  }

  Future<void> _checkStreamAvailability() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse(widget.streamUrl)).timeout(const Duration(seconds: 3));
      setState(() {
        _streamAvailable = response.statusCode == 200;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _streamAvailable = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_streamAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Stream not available', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _checkStreamAvailability,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: WebViewWidget(controller: _controller),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
