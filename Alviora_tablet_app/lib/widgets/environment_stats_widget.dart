import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EnvironmentStatsWidget extends StatefulWidget {
  const EnvironmentStatsWidget({super.key});

  @override
  State<EnvironmentStatsWidget> createState() => _EnvironmentStatsWidgetState();
}

class _EnvironmentStatsWidgetState extends State<EnvironmentStatsWidget> {
  double? temperature;
  String airQuality = 'Loading...';

  final DatabaseReference dhtRef = FirebaseDatabase.instance.ref('dht22_sensor');
  final DatabaseReference gasRef = FirebaseDatabase.instance.ref('gas_sensor');

  @override
  void initState() {
    super.initState();

    // Listen to DHT22 temperature updates
    dhtRef.orderByKey().limitToLast(1).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final last = snapshot.children.first.value as Map<dynamic, dynamic>;
        final tempVal = (last['temperature_c'] as num?)?.toDouble();
        if (tempVal != null) {
          setState(() {
            temperature = tempVal;
          });
        }
      }
    });

    // Listen to MQ135 and MQ2 gas values
    gasRef.orderByKey().limitToLast(1).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final last = snapshot.children.first.value as Map<dynamic, dynamic>;
        final mq135 = (last['mq135'] as num?)?.toDouble() ?? 0.0;
        final mq2 = (last['mq2'] as num?)?.toDouble() ?? 0.0;

        setState(() {
          airQuality = _evaluateAirQuality(mq135, mq2);
        });
      }
    });
  }

  String _evaluateAirQuality(double mq135, double mq2) {
    /*
      ✅ Classification Grid (generalized for indoor environment):

      | MQ135 (pollution) | MQ2 (smoke/gas) | Air Quality  |
      |-------------------|------------------|--------------|
      | < 60              | < 60             | GOOD         |
      | < 100             | < 100            | MODERATE     |
      | >= 100            | >= 100           | POOR         |
      | >= 150            | any              | VERY POOR    |
    */

    if (mq135 >= 150) {
      return 'VERY POOR';
    } else if (mq135 >= 100 || mq2 >= 100) {
      return 'POOR';
    } else if (mq135 >= 60 || mq2 >= 60) {
      return 'MODERATE';
    } else {
      return 'GOOD';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('ROOM TEMP', style: TextStyle(fontSize: 16)),
        Text(
          temperature != null ? '${temperature!.toStringAsFixed(1)}°C' : 'Loading...',
          style: const TextStyle(fontSize: 32, color: Color(0xFF5EA8FF)),
        ),
        const SizedBox(height: 20),
        const Text('AIR QUALITY', style: TextStyle(fontSize: 16)),
        Text(
          airQuality,
          style: const TextStyle(fontSize: 32, color: Color(0xFF5EA8FF)),
        ),
      ],
    );
  }
}
