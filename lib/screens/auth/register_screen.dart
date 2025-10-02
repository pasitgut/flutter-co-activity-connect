import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/components/dropdown_button.dart';
import 'package:flutter_co_activity_connect/components/input_field.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';
import 'package:flutter_co_activity_connect/utils/app_constants.dart';
import 'package:flutter_co_activity_connect/utils/validator.dart';
import 'package:flutter_co_activity_connect/screens/main_screen.dart';
import 'package:flutter_co_activity_connect/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _confirmPasswordCtrl;
  late TextEditingController _majorCtrl;
  bool obscureText = true, confirmObscureText = true;
  String? _selectedYear;
  String? _selectedFaculty;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _majorCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _majorCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      if (_formKey.currentState!.validate()) {
        final response = await _authService.register(
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
          _selectedYear!,
          _selectedFaculty!,
          _majorCtrl.text.trim(),
        );
        debugPrint("Response: ${jsonDecode(response.body)}");
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body)['data'];
          await SecureStorage.writeToken(data['token']);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainScreen()),
            (route) => false,
          );
        } else {
          final error = jsonDecode(response.body)['error'];
          setState(() {
            _errorMessage = error['message'] ?? "Login failed";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not connect to the server';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 32),
                    // Logo
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Hello! Register to get started",
                        style: TextStyle(fontSize: 36),
                      ),
                    ),
                    SizedBox(height: 64),
                    InputField(
                      autofocus: true,
                      text: "Username",
                      hintText: "Enter your username",
                      controller: _usernameCtrl,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.name,
                      validator: (v) => Validator.validateUsername(v),
                    ),
                    SizedBox(height: 16),
                    InputField(
                      text: "Email",
                      hintText: "Enter your email",
                      controller: _emailCtrl,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.emailAddress,
                      validator: (v) => Validator.validateKKUMail(v),
                    ),
                    SizedBox(height: 16),
                    InputField(
                      text: "Password",
                      hintText: "Enter your password",
                      controller: _passwordCtrl,
                      obscureText: obscureText,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => obscureText = !obscureText),
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.visiblePassword,
                      validator: (v) => Validator.validatePassword(v),
                    ),
                    SizedBox(height: 16),
                    InputField(
                      text: "Confirm Password",
                      hintText: "Enter your confirm-password",
                      obscureText: confirmObscureText,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => confirmObscureText = !confirmObscureText,
                        ),
                        icon: Icon(
                          confirmObscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),

                      controller: _confirmPasswordCtrl,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.visiblePassword,
                      validator: (v) => Validator.validateConfirmPassword(
                        _passwordCtrl.text.trim(),
                        v!.trim(),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropDownButton<String>(
                      validator: (v) => v == null ? 'Year is required' : null,
                      text: "Year",
                      hintText: "Select your year",
                      items: AppConstants.years,
                      onChanged: (val) => setState(() => _selectedYear = val),
                      value: _selectedYear,
                    ),

                    SizedBox(height: 16),
                    DropDownButton(
                      validator: (v) =>
                          v == null ? "Faculty is required" : null,
                      text: "Faculty",
                      hintText: "Select your faculty",
                      items: AppConstants.faculties,
                      onChanged: (val) =>
                          setState(() => _selectedFaculty = val),
                      value: _selectedFaculty,
                    ),
                    SizedBox(height: 16),
                    InputField(
                      text: "Major",
                      hintText: "Enter your major",
                      controller: _majorCtrl,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.name,
                      validator: (v) => v!.isEmpty ? "Major is required" : null,
                      onSubmitted: (v) => _submitForm(),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ElevatedButton(
                        onPressed: () => _submitForm(),

                        style: ElevatedButton.styleFrom(
                          // padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shadowColor: AppColors.primaryColor,
                          elevation: 8,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator.adaptive()
                            : Text("Sign up"),
                      ),
                    ),
                    SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        text: "Already have account?",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "\t\t\tSign in",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
