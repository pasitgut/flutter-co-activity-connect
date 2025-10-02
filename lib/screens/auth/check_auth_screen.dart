import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';

import 'package:flutter_co_activity_connect/screens/auth/login_screen.dart';
import 'package:flutter_co_activity_connect/screens/main_screen.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  String? _token;

  Future<void> checkAuth() async {
    _token = await SecureStorage.readToken();
    debugPrint("Token on Check auth screen: $_token");
    if (_token == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
