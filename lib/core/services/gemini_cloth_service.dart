import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiClothService {
  // Use 10.0.2.2 for Android Emulator to access localhost
  // Use localhost for iOS Simulator
  static const String _baseUrl = 'http://10.0.2.2/php_api/analyze_outfit.php';

  Future<Map<String, dynamic>?> analyzeImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      // Attach image
      final file = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(file);

      // Send
      debugPrint("Sending image to Gemini Backend: $_baseUrl");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint("Gemini Backend Response: ${response.body}");
        return jsonDecode(response.body);
      } else {
        debugPrint("Gemini Backend Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Gemini Service Error (Offline?): $e");
      return null;
    }
  }
}
