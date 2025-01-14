import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyampah_app/main.dart';

class ChallengeService {
  static String baseUrl = AppConfig().baseURL;

  static Future<List<Map<String, dynamic>>> getAllChallenges(String token) async {
    final url = Uri.parse('$baseUrl/api/v1/challenge');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final List<dynamic> challengesData = responseData['data'];

      return challengesData.map<Map<String, dynamic>>((challenge) {
        final challengeDetail = challenge['challenge'];
        return {
          'id': challenge['id'],
          'userId': challenge['user_id'],
          'challengeId': challenge['challenge_id'],
          'status': challenge['status'],
          'progress': challenge['progress'],
          'claimable': challenge['claimable'],
          'claimedAt': challenge['claimed_at'],
          'challengeName': challengeDetail['challenge_name'],
          'challengeDescription': challengeDetail['description'],
          'requiredPoints': challengeDetail['required_points'],
          'rewardPoints': challengeDetail['reward_points'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch challenges: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getChallengeDetail(String token, int challengeId) async {
    final url = Uri.parse('$baseUrl/api/v1/challenge/$challengeId');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['data'];
    } else {
      throw Exception('Failed to fetch challenge details: ${response.body}');
    }
  }

  


}