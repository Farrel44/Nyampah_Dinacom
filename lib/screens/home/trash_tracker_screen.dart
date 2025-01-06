import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';

class TrashHistory extends StatefulWidget {
  const TrashHistory({super.key});

  @override
  State<TrashHistory> createState() => _TrashHistoryState();
}

class _TrashHistoryState extends State<TrashHistory> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
                fontSize: size.width * 0.065),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(basePadding),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
