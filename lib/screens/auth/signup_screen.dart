import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/components/input_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
                            labelText: "Username",
                            hintText: 'username',
                            controller: _usernameController,
                            validator: (String? p1) {},
                          ),
                          InputField(
                            labelText: "Email",
                            hintText: 'username@kkumail.com',
                            controller: _emailController,
                            validator: (String? p1) {},
                          ),
                          InputField(
                            autoFocus: true,
                            labelText: "Password",
                            hintText: 'password',
                            controller: _passwordController,
                            validator: (String? p1) {},
                          ),
                          // InputField(
                          //   autoFocus: true,
                          //   labelText: "Year",
                          //   hintText: 'year',
                          // ),
                          // InputField(
                          //   autoFocus: true,
                          //   labelText: "สาขา",
                          //   hintText: 'วิทยาการคอมพิวเตอร์',
                          // ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              maximumSize: Size(double.infinity, 50),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text("Sign up"),
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
                            Navigator.pop(context);
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
