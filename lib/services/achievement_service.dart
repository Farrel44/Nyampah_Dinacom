import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyampah_app/main.dart';

class AchievementService {
  static String baseUrl = AppConfig().baseURL;

  static Future<List<Map<String, dynamic>>> getAllAchievements(String token) async {
    final url = Uri.parse('$baseUrl/api/v1/achievements');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final List<dynamic> achievementsData = responseData['data'];

      return achievementsData.map<Map<String, dynamic>>((achievement) {
        final achievementDetail = achievement['achievement'];
        return {
          'id': achievement['id'],
          'userId': achievement['user_id'],
          'achievementId': achievement['achievement_id'],
          'status': achievement['status'],
          'progress': achievement['progress'],
          'claimable': achievement['claimable'],
          'achievementName': achievementDetail['name'],
          'achievementDescription': achievementDetail['description'],
          'requiredPoints': achievementDetail['required_points'],
          'rewardPoints': achievementDetail['reward_points'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch achievements: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getAchievementDetail(String token, int achievementId) async {
    final url = Uri.parse('$baseUrl/api/v1/achievements/$achievementId');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final Map<String, dynamic> achievementData = responseData['data'];
      final Map<String, dynamic> achievementDetail = achievementData['achievement'];

      return {
        'id': achievementData['id'],
        'userId': achievementData['user_id'],
        'achievementId': achievementData['achievement_id'],
        'status': achievementData['status'],
        'progress': achievementData['progress'],
        'claimable': achievementData['claimable'],
        'achievementName': achievementDetail['name'],
        'achievementDescription': achievementDetail['description'],
        'requiredPoints': achievementDetail['required_points'],
        'rewardPoints': achievementDetail['reward_points'],
      };
    } else {
      throw Exception('Failed to fetch achievement detail: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> claimAchievement(String token, int achievementId) async {
    final url = Uri.parse('$baseUrl/api/v1/achievements/claim/$achievementId');

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
      throw Exception('Failed to claim achievement: ${response.body}');
    }
  }
}