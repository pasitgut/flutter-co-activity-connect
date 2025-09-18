import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/screens/main_screen.dart';
import 'package:flutter_co_activity_connect/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // ถ้า login สำเร็จ → redirect ไป MainScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState['user'] != null) {
        print("Auth State: ${authState['user']}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                log(
                  "Email: ${emailController.text} || Password: ${passwordController.text}",
                );
                await ref
                    .read(authProvider.notifier)
                    .login(emailController.text, passwordController.text);
              },
              child: const Text("Login"),
            ),
            if (authState['loading'] == true) const CircularProgressIndicator(),
            if (authState['error'] != null)
              Text("Error: ${authState['error']}"),
          ],
        ),
      ),
    );
  }
}
