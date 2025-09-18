import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
const KEY = "JWT_TOKEN";
Future<void> saveToken(String token) async {
  await storage.write(key: KEY, value: token);
}

Future<String?> getToken() async {
  return await storage.read(key: KEY);
}

Future<void> deleteToken() async {
  await storage.delete(key: KEY);
}
