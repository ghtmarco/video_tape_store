import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_tape_store/models/video_tape.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.110:3000/api';

  static Future<List<VideoTape>> getVideoTapes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/videotapes'));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');  // Tambahkan print untuk debug

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VideoTape.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load video tapes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting video tapes: $e');  // Tambahkan print untuk debug
      throw Exception('Error: $e');
    }
  }
}
