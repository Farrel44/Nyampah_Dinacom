import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyampah_app/main.dart';

class TrashService {
  static String baseUrl = AppConfig().baseURL;

  static Future<List<Map<String, dynamic>>> getTrashByGroupData(
      String token, String period) async {
    final url = Uri.parse('$baseUrl/api/v1/get-trash/$period');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['data'] != null) {
        return List<Map<String, dynamic>>.from(responseData['data']);
      } else {
        throw Exception('No data found in the response.');
      }
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }

}