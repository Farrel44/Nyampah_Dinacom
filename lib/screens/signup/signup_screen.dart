import 'package:flutter/material.dart';
import 'package:nyampah_app/screens/login/login_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisibility = false;

  @override

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF5F4ED),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double scale = constraints.maxWidth / 375;
              double buttonWidth = constraints.maxWidth * 0.9;
              return Align(
                alignment: AlignmentDirectional.center,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(vertical: 25 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome To Nyampah!',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: const Color(0xFF00693E),
                              fontSize: 30 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Please sign up first',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: const Color(0xFF00693E),
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                      child: Column(
                        children: [
                          buildInputField(
                            context,
                            label: 'Username',
                            controller: usernameController,
                            scale: scale,
                            
                          ),
                          SizedBox(height: 20 * scale),
                          buildInputField(
                            context,
                            label: 'Email',
                            controller: emailController,
                            scale: scale,
                          ),
                          SizedBox(height: 20 * scale),
                          buildInputField(
                            context,
                            label: 'Password',
                            controller: passwordController,
                            isPassword: true,
                            passwordVisibility: passwordVisibility,
                            onVisibilityToggle: () {
                              setState(() {
                                passwordVisibility = !passwordVisibility;
                              });
                            },
                            scale: scale,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    ElevatedButton(
                      onPressed: () {
                        print('Sign Up pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00693E),
                        minimumSize: Size(buttonWidth, 48 * scale),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0 * scale,
                          vertical: 12.0 * scale,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0 * scale),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: const Color(0xFF00693E),
                            fontSize: 14 * scale,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },  
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: const Color(0xFFFF8302),
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool passwordVisibility = false,
    VoidCallback? onVisibilityToggle,
    required double scale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: const Color(0xFF00693E),
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2 * scale),
        TextField(
          controller: controller,
          obscureText: isPassword && !passwordVisibility,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xFF00693E),
                width: 0.5 * scale,
              ),
              borderRadius: BorderRadius.circular(8.0 * scale),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xFF00693E),
                width: 0.5 * scale,
              ),
              borderRadius: BorderRadius.circular(8.0 * scale),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      passwordVisibility
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 22 * scale,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
          ),
          style: TextStyle(
            fontFamily: 'Inter',
            color: const Color(0xFF00693E),
            fontSize: 14 * scale,
          ),
        ),
      ],
    );
  }
}

