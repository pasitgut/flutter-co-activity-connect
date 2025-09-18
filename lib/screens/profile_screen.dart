import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/screens/auth/signin_screen.dart';
import 'package:flutter_co_activity_connect/utils/secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? token;

  Future<void> loadToken() async {
    print("Get Token");
    String? storedToken = await getToken();
    setState(() {
      token = storedToken;
    });
  }

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Profile"),
        actions: [
          IconButton(
            onPressed: () async {
              await deleteToken();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SigninScreen()),
              );
            },
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(child: Container(child: Text(token ?? "Token not found"))),
    );
  }
}
