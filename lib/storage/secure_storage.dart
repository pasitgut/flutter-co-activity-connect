import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();
  static final _key = "TOKEN";

  static Future<void> writeToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  static Future<String?> readToken() async {
    return await _storage.read(key: _key);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _key);
  }
}
