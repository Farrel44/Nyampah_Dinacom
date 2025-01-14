import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:nyampah_app/services/voucher_service.dart';
import 'package:nyampah_app/services/user_service.dart';

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
      final fetchedVouchers = await VoucherService.getAllVouchers(token);
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
          SnackBar(content: Text('Gagal mengambil data voucher!')),
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
      //app bar poin
      appBar: AppBar(
        actions: [
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              width: size.width * 0.225,
              height: size.width * 0.18,
              decoration: BoxDecoration(
              color: greenColor,
              borderRadius: BorderRadius.circular(basePadding * 1.4),
              ),
              child: Center(
              child: Text(
                '${user?['points'] ?? 0} Poin',
                textAlign: TextAlign.center,
                style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                ),
              ),
              ),
            ),
            )
        ],
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
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator(color: const Color(0xFF00693E)))
              : vouchers.isEmpty
                  ? const Center(
                      child: Text(
                        "Tidak ada voucher yang tersedia.",
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
                                                  fontSize: 20,
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
                                              onTap: () async {
                                                try {
                                                  final voucherDetail = await VoucherService.getVoucherDetail(token!, vouchers[index]['id']);
                                                    showDialog(
                                                      context: context,
                                                        builder: (BuildContext context) {
                                                        return VoucherDetailDialog(
                                                          token: token!,
                                                          name: voucherDetail['reward_name'],
                                                          cost: voucherDetail['points_required'],
                                                          desc: voucherDetail['description'],
                                                          voucherId: vouchers[index]['id'],
                                                        );
                                                      },
                                                    );                                                
                                                  } 
                                                  catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Gagal mengambil detail voucher!')),
                                                  );
                                                }
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
        ],
      ),
    );
  }
}


class VoucherDetailDialog extends StatelessWidget {
  final String name;
  final int cost;
  final String desc;
  final int voucherId;
  final String token;

  const VoucherDetailDialog({
    Key? key,
    required this.name,
    required this.cost,
    required this.desc,
    required this.voucherId,
    required this.token,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: screenWidth * 0.95,
        height: screenHeight * 0.5,
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tukar Voucher',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: greenColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: greenColor),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              // Fetch user data
                              try {
                                final prefs = await SharedPreferences.getInstance();
                                final token = prefs.getString('token');

                                if (token != null) {
                                  final userData = await UserService.getUserByName(token);
                                  await prefs.setString('user', jsonEncode(userData));
                                } else {
                                  throw Exception('Token not found');
                                }
                              } catch (e) {
                                // Handle error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to fetch user data')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12), // Kurangi jarak
                      // Voucher Name Section
                      Text(
                        'Nama Voucher',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                      const SizedBox(height: 6), // Kurangi jarak
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 101, 101, 101),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Cost Section
                      Text(
                        'Biaya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$cost Points',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 101, 101, 101),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 101, 101, 101),
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
              try {
                Navigator.pop(context); // Close the current dialog
                showDialog(
                context: context,
                
                builder: (BuildContext context) {
                  return RedeemDialog(
                    token: token, // Replace `userToken` with the actual token value in your code
                    voucherId: voucherId, // Replace `selectedVoucherId` with the actual voucher ID
                  );
                },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menukarkan voucher!')),
                );
              }
              },
              child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
                ),
                color: greenColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                  'Tukar',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 24,
                ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RedeemDialog extends StatelessWidget {
  final String token;
  final int voucherId;

  const RedeemDialog({
    super.key,
    required this.token,
    required this.voucherId,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formatter = DateFormat("d MMMM yyyy • HH.mm 'WIB'");
    final formattedTime = formatter.format(now);

    return FutureBuilder<Map<String, dynamic>>(
      future: VoucherService.redeemVoucher(token, voucherId),
      builder: (context, redeemSnapshot) {
        if (redeemSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (redeemSnapshot.hasError) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal menukar voucher',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    redeemSnapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          );
        } else if (redeemSnapshot.hasData) {
          final redeemData = redeemSnapshot.data;
          return FutureBuilder<Map<String, dynamic>>(
            future: VoucherService.getVoucherDetail(token, voucherId),
            builder: (context, detailSnapshot) {
              if (detailSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (detailSnapshot.hasError) {
                return const Center(
                  child: Text("Gagal memuat detail voucher."),
                );
              } else if (detailSnapshot.hasData) {
                final detailData = detailSnapshot.data;

                return Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.9,
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(Icons.close_outlined, color: Colors.green),
                                ),
                              ),
                              Center(
                                child: SvgPicture.asset(
                                  'assets/images/daun_redeem.svg',
                                  height: 120,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  "Penukaran Berhasil!",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                                Center(
                                child: Text(
                                  "Kode Voucher",
                                  style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  ),
                                ),
                                ),
                                const SizedBox(height: 4),
                                Center(
                                child: Text(
                                  redeemData?['data']['voucher'] ?? 'Unknown Voucher',
                                  style: const TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  ),
                                ),
                                ),
                              const SizedBox(height: 20),
                              Text(
                                "Nama",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                detailData?['reward_name'] ?? 'Hadiah tidak diketahui',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Biaya",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${detailData?['points_required'] ?? 'Unknown'} Points',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Deskripsi",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${detailData?['description'] ?? 'Deskripsi tidak diketahui'}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Ditukar pada",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              return const Center(
                child: Text("Terjadi kesalahan"),
              );
            },
          );
        }

        return const Center(
          child: Text("Terjadi kesalahan"),
        );
      },
    );
  }
}