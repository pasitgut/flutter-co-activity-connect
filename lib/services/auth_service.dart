import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:flutter_co_activity_connect/services/api_service.dart';
import "package:http/http.dart" as http;

class AuthService {
  Future<http.Response> register(
    String username,
    String email,
    String password,
    String year,
    String faculty,
    String major,
  ) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/auth/register");
    final response = await http.post(
      url,
      headers: ApiService.getHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'year_level': year,
        'faculty': faculty,
        'major': major,
      }),
    );

    return response;
  }

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/auth/login');
    final response = await http.post(
      url,
      headers: ApiService.getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      debugPrint("Data: $data");
      await SecureStorage.writeToken(data['data']['token']);
    }

    return response;
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
  }
}
