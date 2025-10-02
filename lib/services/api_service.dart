import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';

class ApiService {
  static const baseUrl = "https://backend.pasitlab.com";

  static Future<String?> _getToken() async {
    return await SecureStorage.readToken();
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await SecureStorage.readToken();
    if (token == null) {
      debugPrint("Token not found");
      return {"Content-Type": "application/json"};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> getHeaders() {
    return {'Content-Type': 'application/json'};
  }
}
