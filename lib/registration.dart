import 'package:allah_every_where/registration_success.dart';
import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/widgets/buttons_section.dart';
import 'package:allah_every_where/widgets/form_section.dart';
import 'package:allah_every_where/widgets/login_link.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isChecked = false;
  bool _isFormValid = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _checkFormValidity() {
    setState(() {
      _isFormValid = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text &&
          _isChecked;
    });
  }

  Future<void> _registerWithEmailPassword() async {
    try {
      // Get email and password from controllers
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to registration success page if registration is successful
      Get.to(() => RegistrationSuccess());
    } catch (e) {
      // Handle errors (e.g., email already in use)
      String errorMessage = "An error occurred during registration.";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = "The password is too weak.";
            break;
          case 'email-already-in-use':
            errorMessage = "The email is already in use.";
            break;
          default:
            errorMessage = "An error occurred. Please try again.";
            break;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoidColors.primary,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/blur_top.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  FormSection(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    isChecked: _isChecked,
                    onCheckboxChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                        _checkFormValidity();
                      });
                    },
                    onTextChanged: (value) => _checkFormValidity(),
                  ),
                  SizedBox(height: 20.h),
                  ButtonsSection(
                    isFormValid: _isFormValid,
                    onRegisterPressed: () {
                      if (_isFormValid) {
                        _registerWithEmailPassword(); // Call the Firebase registration method
                      }
                    },
                    onJoinAsGuestPressed: () {
                      // Join as guest logic goes here
                    },
                  ),
                  SizedBox(height: 20.h),
                  LoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
