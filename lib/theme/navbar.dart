import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/main.dart';

class FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final GlobalKey? voucherKey;
  final GlobalKey? homeKey;
  final GlobalKey? scanKey;
  final GlobalKey? profileKey;
  final GlobalKey? trashKey;

  const FloatingBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    this.voucherKey,
    this.homeKey,
    this.scanKey,
    this.profileKey,
    this.trashKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          Alignment.bottomCenter, // Ensures it's positioned at the bottom
      child: Padding(
        padding: const EdgeInsets.only(
            bottom: 16), // Avoid overlapping with gestures
        child: Material(
          color:
              Colors.transparent, // Ensures background doesn't take full screen
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.1,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5F1),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    key: voucherKey,
                    label: 'Voucher',
                    icon: Icons.confirmation_number_outlined,
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    key: homeKey,
                    label: 'Home',
                    icon: Icons.home_outlined,
                    isSelected: selectedIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _CenterButton(
                    key: scanKey,
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    key: profileKey,
                    label: 'Profile',
                    icon: Icons.person_outline,
                    isSelected: selectedIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    key: trashKey,
                    label: 'Trash',
                    icon: CupertinoIcons.delete,
                    isSelected: selectedIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final GlobalKey? key;

  const _NavItem({
    this.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? greenColor : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? greenColor : Colors.grey,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final GlobalKey? key;

  const _CenterButton({
    this.key,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.camera_viewfinder,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
