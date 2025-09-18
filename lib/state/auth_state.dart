import 'dart:developer';

import 'package:flutter_co_activity_connect/api/auth_api.dart';
import 'package:flutter_co_activity_connect/utils/secure_storage.dart';
import 'package:riverpod/legacy.dart';

class AuthNotifier extends StateNotifier<Map<String, dynamic>> {
  AuthNotifier() : super({});

  final api = AuthApi();

  Future<void> login(String email, String password) async {
    state = {"loading": true};
    try {
      final res = await api.login(email, password);

      final token = res['token'];
      if (token != null) {
        await saveToken(token);
      }
      state = {"loading": false, "user": res};
    } catch (err) {
      log("Error: ${err.toString()}");
      state = {"loading": false, "error": err.toString()};
    }
  }

  Future<void> logout() async {
    await deleteToken();
    state = {};
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, Map<String, dynamic>>(
  (ref) => AuthNotifier(),
);
