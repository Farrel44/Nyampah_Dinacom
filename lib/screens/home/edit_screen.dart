import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:nyampah_app/theme/colors.dart';
import 'package:nyampah_app/main.dart';
import 'package:nyampah_app/services/user_service.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Map<String, dynamic>? user;
  String? token;

  File? image;

  Future<void> pickImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;
      setState(() {
        image = File(pickedImage.path);
      });
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
  
  @override
  void initState() {
    super.initState();
    loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUserData();
    });
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final userToken = prefs.getString('token');

    if (userData != null) {
      setState(() {
        user = jsonDecode(userData);
        token = userToken;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = AppConfig().baseURL;
    final size = MediaQuery.of(context).size;
    final double basePadding = size.width * 0.05;
    final double profileSize = size.width * 0.28;
    final double editButtonSize = profileSize * 0.3;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.chevron_left,
            color: greenColor,
            size: size.width * 0.1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: image != null
                        ? Image.file(
                          image!,
                          fit: BoxFit.cover,
                          width: profileSize,
                          height: profileSize,
                        )
                        : user?['profile_image'] != null
                          ? Image.network(
                            '$baseUrl/storage/${user?['profile_image']}',
                            width: profileSize,
                            height: profileSize,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            'assets/images/placeholder_image.png',
                            width: profileSize,
                            height: profileSize,
                            fit: BoxFit.cover,
                          ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: editButtonSize,
                          height: editButtonSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: greenColor,
                            size: editButtonSize * 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  width: size.width,
                  padding: EdgeInsets.all(basePadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Username'),
                      _buildTextInput(
                          usernameController, 'Update your username'),
                      SizedBox(height: size.height * 0.015),
                      _buildLabel('Password'),
                      _buildTextInput(
                          passwordController, 'Update your password',
                          isObscure: true),
                      SizedBox(height: size.height * 0.010),
                    ],
                  ),
                ),
                SizedBox(height: basePadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: size.width / 3,
                      height: size.height * 0.045,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (token == null) {
                              throw Exception("Token is not available. Please log in again.");
                            }

                            final String username = usernameController.text.trim();
                            final String password = passwordController.text.trim();
                            String? profileImagePath = image?.path;

                            bool hasUpdates = false;

                            if (username.isNotEmpty && username != user?['name']) {
                              hasUpdates = true;
                            }

                            if (password.isNotEmpty) {
                              hasUpdates = true;
                            }

                            if (profileImagePath != null) {
                              hasUpdates = true;
                            }

                            if (!hasUpdates) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("No changes to update.")),
                              );
                              return;
                            }

                            final updatedData = await UserService.updateProfile(
                              token: token!,
                              name: username.isNotEmpty ? username : null,
                              password: password.isNotEmpty ? password : null,
                              profileImagePath: profileImagePath,
                            );

                            if (updatedData.containsKey('name')) {
                              user?['name'] = updatedData['name'];
                            }
                            if (updatedData.containsKey('password')) {
                              user?['password'] = password;
                            }
                            if (updatedData.containsKey('profile_image')) {
                              user?['profile_image'] = updatedData['profile_image'];
                            }

                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString('user', jsonEncode(user));

                            await loadUserData();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profile updated successfully!")),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Submit",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: size.width * 0.035,
                                  color: greenColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.edit,
                              color: greenColor,
                              size: editButtonSize * 0.6,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: greenColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String hint,
      {bool isObscure = false}) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.07,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        style: TextStyle(
          color: greenColor,
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.width * 0.04,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: greenColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: const Color(0xFFF4F5F0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.015,
            horizontal: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
      ),
    );
  }
}
