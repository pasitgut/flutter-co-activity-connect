import "package:dio/dio.dart";

final dio = Dio(
  BaseOptions(
    baseUrl: "http://10.0.3.2:3000/api",
    headers: {'Content-Type': 'application/json'},
  ),
);
