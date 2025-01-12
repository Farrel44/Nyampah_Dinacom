import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nyampah_app/main.dart';

class ScanService {
  static String baseUrl = AppConfig().baseURL;
  static Future<Map<String, dynamic>> scanImage(String token, File imageFile) async {
    final url = Uri.parse('$baseUrl/api/v1/scan-image');

    final request = http.MultipartRequest('POST', url)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('trash_image', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> json = jsonDecode(responseData);

      return {
        'trash_image': json['data']['trash_image'],
        'trash_name': json['data']['trash_name'],
        'description': json['data']['description'],
        'category': json['data']['category'],
        'pengelolaan': json['data']['pengelolaan'],
        'trash_quantity': json['data']['trash_quantity'],
      };
    } else {
      final errorResponse = await response.stream.bytesToString();
      throw Exception('Failed to scan image: $errorResponse');
    }
  }
}