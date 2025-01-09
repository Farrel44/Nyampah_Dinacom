import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://289a-36-73-34-81.ngrok-free.app/api/v1';

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

  static Future<List<Map<String, dynamic>>> getAllVouchers(String token) async {
    final url = Uri.parse('$baseUrl/get-all-vouchers');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final List<dynamic> rewardsData = responseData['data'];

      return rewardsData.map<Map<String, dynamic>>((reward) {
        return {
          'rewardName': reward['reward_name'],
          'rewardImage': reward['reward_image'],
          'description': reward['description'],
          'pointsRequired': reward['points_required'],
          'stock': reward['stock'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch vouchers: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getTrashByGroupData(
      String token, String period) async {
    final url = Uri.parse('$baseUrl/get-trash/$period');
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

  static Future<Map<String, dynamic>> scanImage(String token, File imageFile) async {
    final url = Uri.parse('$baseUrl/scan-image');

    final request = http.MultipartRequest('POST', url)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('trash_image', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 201) {
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

  static Future<Map<String, dynamic>> getVoucherDetail(String token, int id) async {
    final url = Uri.parse('$baseUrl/voucher/$id');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch voucher detail: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> redeemVoucher(String token, int voucherId) async {
    final url = Uri.parse('$baseUrl/voucher-redeem/$voucherId');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to redeem voucher: ${response.body}');
    }
  }
  
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? password,
    String? profileImagePath,
  }) async {
    final uri = Uri.parse('$baseUrl/update');

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
  final url = Uri.parse('$baseUrl/update-profile-image');

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


  
}
