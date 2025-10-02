import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/services/api_service.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<http.Response> updateProfile(
    String userId,
    String username,
    String year,
    String faculty,
    String major,
    String bio,
    bool isPrivate,
  ) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/profile/");
    final response = await http.put(
      url,
      headers: await ApiService.getAuthHeaders(),
      body: jsonEncode({
        'user_id': userId,
        'username': username,
        'year': year,
        'faculty': faculty,
        'major': major,
        'bio': bio,
        // 'is_private': isPrivate,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Data: $data");
      await SecureStorage.writeToken(data['data']['token']);
    }
    return response;
  }
}
