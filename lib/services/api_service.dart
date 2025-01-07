import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://nyampah.my.id/api/v1';

  static Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');

    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
    });

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }


  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard(String token) async {
    final url = Uri.parse('$baseUrl/leaderboard');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the "data" field
      final List<dynamic> leaderboardData = responseData['data'][0];

      // Map each leaderboard entry to a usable format
      return leaderboardData.map<Map<String, dynamic>>((entry) {
        return {
          'name': entry['name'],
          'email': entry['email'],
          'profileImage': entry['profile_image'],
          'points': entry['points'],
          'rank': entry['rank'],
          'uuid': entry['uuid'],
          'exp': entry['exp'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch leaderboard: ${response.body}');
    }
  }

}
