import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/components/input_field.dart';
import 'package:flutter_co_activity_connect/screens/auth/signup_screen.dart';
import 'package:flutter_co_activity_connect/utils/routes.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();

    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 16.0,
                right: 16.0,
                bottom: 24.0,
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 150, width: 150, color: Colors.red),
                    SizedBox(height: 64),
                    Form(
                      child: Column(
                        spacing: 24.0,
                        children: [
                          InputField(
                            autoFocus: true,
                            labelText: "Email",
                            hintText: 'username@kkumail.com',
                            controller: _emailController,
                            validator: (String? p1) {
                              if (p1!.isEmpty) {
                                return "Email must not be empty";
                              }
                            },
                          ),

                          InputField(
                            autoFocus: false,
                            labelText: "Password",
                            hintText: 'password',
                            controller: _passwordController,
                            validator: (String? p1) {
                              if (p1!.isEmpty) {
                                return "Password must not be empty";
                              }
                            },
                          ),

                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              maximumSize: Size(double.infinity, 50),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text("Sign in"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).push(createRoute(const SignupScreen()));
                          },
                          child: Text("Sign up"),
                        ),
                      ],
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
