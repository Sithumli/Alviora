import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String weatherState = 'Loading';
  String temperature = '--';
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      // Use a hardcoded city name instead of LocationService
      final city = 'Colombo';
      // Fetch weather using WeatherAPI.com API
      final apiKey = '9c3d166e839148e99d0212629251206';
      final url = Uri.parse('https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no');
      final response = await http.get(url);
      print('Weather API Response: \\n${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          setState(() {
            _error = data['error']['message'] ?? 'Weather API error.';
            _loading = false;
          });
          return;
        }
        setState(() {
          weatherState = data['current']['condition']['text'];
          temperature = data['current']['temp_c'].toStringAsFixed(1);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load weather data: \\n${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Weather error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Row(children: [CircularProgressIndicator()]);
    }
    if (_error.isNotEmpty) {
      return Row(children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Flexible(child: Text(_error, style: TextStyle(color: Colors.red)))],);
    }
    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weatherState, style: const TextStyle(fontSize: 28)),
                Text(
                  '$temperature°C',
                  style: const TextStyle(
                    color: Color(0xFF5EA8FF),
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Icon(
              weatherState.toLowerCase().contains('cloud')
                  ? Icons.cloud
                  : weatherState.toLowerCase().contains('rain')
                      ? Icons.grain
                      : Icons.wb_sunny_rounded,
              color: Colors.orange,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
