import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detection_model.dart';

class DetectionService {
  static const String baseUrl = 'https://example.com/api'; // Replace with your real API

  static Future<List<Detection>> fetchDetections(String type) async {
    final response = await http.get(Uri.parse('$baseUrl/$type'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Detection.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load detections');
    }
  }
}
