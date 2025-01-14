import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nyampah_app/main.dart';

class UserService {
  static String baseUrl = AppConfig().baseURL;
  
  static Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/v1/register');

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
    final url = Uri.parse('$baseUrl/api/v1/login');

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
    final url = Uri.parse('$baseUrl/api/v1/leaderboard');

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
  
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? password,
    String? profileImagePath,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/update');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..fields['_method'] = 'PUT';

    // Add optional fields
    if (name != null && name.isNotEmpty) {
      request.fields['name'] = name;
    }
    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
    }
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        profileImagePath,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody)['data'];
    } else {
      final errorResponse = await response.stream.bytesToString();
      throw Exception('Failed to update profile: $errorResponse');
    }
  }


  static Future<Map<String, dynamic>> updateProfileImage(String token, File imageFile) async {
    final url = Uri.parse('$baseUrl/api/v1/update-profile-image');

    final request = http.MultipartRequest('POST', url)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return jsonDecode(responseData);
    } else {
      final errorResponse = await response.stream.bytesToString();
      throw Exception('Failed to update profile image: $errorResponse');
    }
  }

  static Future<Map<String, dynamic>> getUserByName(String token) async {
    final url = Uri.parse('$baseUrl/api/v1/user-data');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['data']['data'];
    } else {
      throw Exception('Failed to fetch user data: ${response.body}');
    }
  }



}