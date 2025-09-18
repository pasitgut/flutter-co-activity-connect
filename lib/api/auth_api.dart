import 'dart:developer';

import 'package:flutter_co_activity_connect/api/dio_client.dart';

class AuthApi {
  Future<Map<String, dynamic>> regsiter(
    String email,
    String username,
    String password,
  ) async {
    final res = await dio.post(
      "/auth/register",
      data: {'email': email, 'username': username, 'password': password},
    );

    return res.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    log("Email: $email, Password: $password");
    final res = await dio.post(
      "/auth/login",
      data: {'email': email, 'password': password},
    );
    return res.data;
  }
}
