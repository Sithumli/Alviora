import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:async';
import 'video_call_home.dart';
import 'package:firebase_database/firebase_database.dart';

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
            Text("Viewing: Bed Room (${getStreamUrl()})", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // Live Stream Container
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: WebRTCView(streamUrl: getStreamUrl()),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoCallHome())
                );
                  },
                child: _actionButton(Icons.video_call, "Video Call"),
                ),
                _actionButton(Icons.record_voice_over, "Speak"),
                _actionButton(Icons.analytics, "Status"),
                _actionButton(Icons.settings, "Settings"),
              ],
            ),

            const SizedBox(height: 30),

            // Info Cards (Dynamic)
            StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref().onValue,
              builder: (context, snapshot) {
                // Don't show loading animation while waiting for data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text('No sensor data available'));
                }
                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                
                // Get latest dht22_sensor data
                final dhtMap = (data['dht22_sensor'] as Map<dynamic, dynamic>?);
                final dhtLatest = dhtMap != null ? _getLatestReading(dhtMap) : null;
                
                // Get latest ir_motion data
                final irMap = (data['sensor_data'] != null && data['sensor_data']['ir_motion'] != null)
                  ? data['sensor_data']['ir_motion'] as Map<dynamic, dynamic>
                  : null;
                final irLatest = irMap != null ? _getLatestReading(irMap) : null;
                
                // Get latest gas sensor data
                final gasMap = (data['gas_sensor'] as Map<dynamic, dynamic>?);
                final gasLatest = gasMap != null ? _getLatestReading(gasMap) : null;

                // Room Temperature
                String temp = "N/A";
                String tempStatus = "";
                if (dhtLatest != null && dhtLatest['temperature_c'] != null) {
                  final tempVal = dhtLatest['temperature_c'];
                  temp = "$tempVal°C";
                  if (tempVal is num) {
                    if (tempVal > 35) {
                      tempStatus = "(High)";
                    } else if (tempVal < 18) {
                      tempStatus = "(Low)";
                    } else {
                      tempStatus = "(Normal)";
                    }
                  }
                }

                // Air Quality
                String airQuality = "N/A";
                if (gasLatest != null) {
                  int? mq135;
                  try {
                    mq135 = gasLatest['mq135'] is int
                        ? gasLatest['mq135']
                        : int.tryParse(gasLatest['mq135'].toString());
                  } catch (e) {
                    mq135 = null;
                  }
                  String qualityLabel = "Neutral";
                  if (mq135 != null) {
                    if (mq135 <= 50) {
                      qualityLabel = "Good";
                    } else if (mq135 > 100) {
                      qualityLabel = "Bad";
                    } else {
                      qualityLabel = "Neutral";
                    }
                  }
                  airQuality = qualityLabel;
                  if (mq135 != null) airQuality += " ($mq135)";
                  
                  if (gasLatest['timestamp'] != null) {
                    try {
                      final airTime = DateTime.parse(gasLatest['timestamp'].toString());
                      final now = DateTime.now();
                      if (airTime.isAfter(now)) {
                        airQuality += " - just now";
                      } else {
                        final diff = now.difference(airTime);
                        if (diff.inMinutes < 1) {
                          airQuality += " - just now";
                        } else if (diff.inMinutes < 60) {
                          airQuality += " - ${diff.inMinutes}m ago";
                        } else if (diff.inHours < 24) {
                          airQuality += " - ${diff.inHours}h ago";
                        }
                      }
                    } catch (e) {
                      print('Error parsing air quality timestamp: $e');
                    }
                  }
                }

                // Last Movement
                String lastMove = "N/A";
                String lastMoveAgo = "";
                if (irLatest != null) {
                  lastMove = irLatest['motion_detected'] == true ? "Motion detected" : "No motion";
                  if (irLatest['timestamp'] != null) {
                    try {
                      final lastMoveTime = DateTime.parse(irLatest['timestamp'].toString());
                      final now = DateTime.now();
                      if (lastMoveTime.isAfter(now)) {
                        lastMoveAgo = "just now";
                      } else {
                        final diff = now.difference(lastMoveTime);
                        if (diff.inMinutes < 1) {
                          lastMoveAgo = "just now";
                        } else if (diff.inMinutes < 60) {
                          lastMoveAgo = "${diff.inMinutes}m ago";
                        } else if (diff.inHours < 24) {
                          lastMoveAgo = "${diff.inHours}h ago";
                        } else {
                          lastMoveAgo = "${diff.inDays}d ago";
                        }
                      }
                    } catch (e) {
                      print('Error parsing motion timestamp: $e');
                      lastMoveAgo = "just now";
                    }
                  }
                }

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    InfoCard(title: "Room Temperature", value: "$temp $tempStatus"),
                    InfoCard(title: "Air Quality", value: airQuality),
                    InfoCard(title: "Last Movement", value: "$lastMove ($lastMoveAgo)"),
                    InfoCard(title: "Robot Battery", value: "87% (Charging)"),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String getStreamUrl() {
    // For physical devices, use the actual local IP address
    const String serverIp = '192.168.1.32'; // Your computer's local IP address
    return 'http://192.168.1.32:8080';
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

  Map<dynamic, dynamic> _getLatestReading(Map<dynamic, dynamic> readings) {
    var latestTimestamp = DateTime.fromMillisecondsSinceEpoch(0);
    Map<dynamic, dynamic>? latestReading;
    
    readings.forEach((key, value) {
      if (value is Map && value['timestamp'] != null) {
        try {
          final timestamp = DateTime.parse(value['timestamp'].toString());
          if (timestamp.isAfter(latestTimestamp)) {
            latestTimestamp = timestamp;
            latestReading = value;
          }
        } catch (e) {
          print('Error parsing timestamp for reading: $e');
        }
      }
    });
    
    return latestReading ?? readings.values.last;
  }
}

class WebRTCView extends StatefulWidget {
  final String streamUrl;

  const WebRTCView({super.key, required this.streamUrl});

  @override
  State<WebRTCView> createState() => _WebRTCViewState();
}

class _WebRTCViewState extends State<WebRTCView> {
  bool _loading = true;
  String _errorMessage = '';
  late final WebViewController _controller;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
            setState(() {
              _loading = true;
              _errorMessage = '';
            });
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            setState(() {
              _loading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
            setState(() {
              _loading = false;
              _errorMessage = 'Error: ${error.description}';
            });
            
            // Auto retry after 5 seconds
            _retryTimer?.cancel();
            _retryTimer = Timer(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  _loading = true;
                  _errorMessage = '';
                });
                _initializeWebView();
              }
            });
          },
        ),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation requests
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.streamUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to stream...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Stream not available',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _errorMessage = '';
                });
                _initializeWebView();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry Now"),
            ),
            const SizedBox(height: 8),
            const Text(
              'Auto-retrying in 5 seconds...',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: WebViewWidget(controller: _controller),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 8),
                SizedBox(width: 4),
                Text('Live', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
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
