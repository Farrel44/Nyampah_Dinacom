import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:nyampah_app/services/api_service.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => VoucherPageState();
}

class VoucherPageState extends State<VoucherPage> {
  Map<String, dynamic>? user;
  String? token;
  List<Map<String, dynamic>> vouchers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final userToken = prefs.getString('token');

    if (userData != null && userToken != null) {
      setState(() {
        user = jsonDecode(userData);
        token = userToken;
      });

      await fetchVouchers(userToken);
    }
  }

  Future<void> fetchVouchers(String? token) async {
    if (token == null) return;

    try {
      final fetchedVouchers = await ApiService.getAllVouchers(token);
      if (mounted) {
        setState(() {
          vouchers = fetchedVouchers;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch vouchers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Voucher",
            style: TextStyle(
              color: greenColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.065,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vouchers.isEmpty
              ? const Center(
                  child: Text(
                    "No vouchers available.",
                    style: TextStyle(
                      color: greenColor,
                      fontFamily: 'Inter',
                      fontSize: 16,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(basePadding),
                  child: ListView.builder(
                    itemCount: vouchers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final voucher = vouchers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: size.height * 0.15,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                ClipPath(
                                  child: Container(
                                    width: double.infinity,
                                    height: (size.height * 0.15) * 0.65,
                                    decoration: BoxDecoration(
                                      color: greenColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: basePadding,
                                        vertical: basePadding / 2,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            voucher['rewardName'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 19,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            voucher['description'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Klaim Voucher - ${voucher['pointsRequired']} Poin",
                                          style: const TextStyle(
                                            color: greenColor,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                titlePadding: const EdgeInsets.all(16),
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'Klaim Voucher',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).pop(); // Close the dialog
                                                      },
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Nama",
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${voucher['rewardName']}",
                                                      style: const TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      // Fetch the token from the user's state or storage
                                                      if (token != null) {
                                                        try {
                                                            final voucherId = vouchers.firstWhere((v) => v['rewardName'] == voucher['rewardName'])['id'];
                                                            final response = await ApiService.redeemVoucher(token!, voucherId);
                                                          final voucherCode = response['data']['voucher'];

                                                          // Show a success dialog with the voucher code
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: const Text('Voucher Redeemed'),
                                                                content: Text('Your voucher code: $voucherCode'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop(); // Close the dialog
                                                                    },
                                                                    child: const Text('OK'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        } catch (e) {
                                                          // Handle error
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: const Text('Error'),
                                                                content: Text('Failed to redeem voucher: $e'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop(); // Close the error dialog
                                                                    },
                                                                    child: const Text('OK'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      } else {
                                                        // Handle missing token (optional)
                                                        Navigator.of(context).pop();
                                                      }
                                                    },
                                                    child: const Text(
                                                      'Klaim',
                                                      style: TextStyle(
                                                        color: greenColor,
                                                        fontFamily: 'Inter',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Icon(
                                          Icons.chevron_right,
                                          color: greenColor,
                                        ),
                                      ),

                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
