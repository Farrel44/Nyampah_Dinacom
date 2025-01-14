import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyampah_app/main.dart';

class VoucherService {
  static String baseUrl = AppConfig().baseURL;

  static Future<List<Map<String, dynamic>>> getAllVouchers(String token) async {
    final url = Uri.parse('$baseUrl/api/v1/get-all-vouchers');

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
          'id': reward['id'],
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

  static Future<Map<String, dynamic>> getVoucherDetail(String token, int id) async {
    final url = Uri.parse('$baseUrl/api/v1/voucher/$id');

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
    final url = Uri.parse('$baseUrl/api/v1/voucher-redeem/$voucherId');

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
  
}