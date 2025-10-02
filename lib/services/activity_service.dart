import 'dart:convert';

import 'package:flutter_co_activity_connect/services/api_service.dart';
import 'package:http/http.dart' as http;

class ActivityService {
  Future<http.Response> createActivity(
    String userId,
    String title,
    String description,
    int maxMember,
    bool isPublic,
    List<String> tags,
  ) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/activity");
    final response = await http.post(
      url,
      headers: await ApiService.getAuthHeaders(),
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'description': description,
        'max_member': maxMember,
        'is_public': isPublic,
        'type': '',
        'tags': tags,
      }),
    );

    return response;
  }

  Future<http.Response> joinActivity(int activityId, String userId) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/activity/join");
    final response = await http.post(
      url,
      headers: await ApiService.getAuthHeaders(),
      body: jsonEncode({'activity_id': activityId, 'user_id': userId}),
    );
    return response;
  }

  Future<http.Response> getActivitiesJoined(String userId) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/activity/joined/$userId");
    final response = await http.get(
      url,
      headers: await ApiService.getAuthHeaders(),
    );
    return response;
  }

  Future<http.Response> getActivitiesNotJoined(String userId) async {
    final url = Uri.parse(
      "${ApiService.baseUrl}/api/activity/not-joined/$userId",
    );
    final response = await http.get(
      url,
      headers: await ApiService.getAuthHeaders(),
    );
    return response;
  }

  Future<http.Response> getActivitiesPending(String userId) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/activity/pending/$userId");
    final response = await http.get(
      url,
      headers: await ApiService.getAuthHeaders(),
    );
    return response;
  }

  Future<http.Response> getActivityMembers(int activityId) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/api/activity/members/$activityId',
    );
    final response = await http.get(
      url,
      headers: await ApiService.getAuthHeaders(),
    );

    return response;
  }

  Future<http.Response> updateJoinRequest(
    int activityId,
    String status,
    String userId,
  ) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/activity/join');
    final response = await http.put(
      url,
      headers: await ApiService.getAuthHeaders(),
      body: jsonEncode({
        'activity_id': activityId,
        'status': status,
        'user_id': userId,
      }),
    );

    return response;
  }

  Future<http.Response> rejectUser(int activityId, String userId) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/activity/rejected');
    final response = await http.patch(
      url,
      headers: await ApiService.getAuthHeaders(),
      body: jsonEncode({'activity_id': activityId, 'user_id': userId}),
    );

    return response;
  }

  Future<http.Response> updateActivity(
    int activityId,
    String title,
    String description,
    int maxMember,
    bool isPublic,
    List<String> tags,
  ) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/activity/');
    final response = await http.put(
      url,
      headers: await ApiService.getAuthHeaders(),
      body: jsonEncode({
        'activity_id': activityId,
        'title': title,
        'description': description,
        'max_member': maxMember,
        'is_public': isPublic,
        'tags': tags,
      }),
    );
    return response;
  }
}
