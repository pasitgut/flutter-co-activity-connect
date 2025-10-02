import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/model/activity.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';
import 'package:flutter_co_activity_connect/screens/activity/activity_details_screen.dart';
import 'package:flutter_co_activity_connect/screens/activity/create_activity_screen.dart';
import 'package:flutter_co_activity_connect/services/activity_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_co_activity_connect/services/api_service.dart'; // ต้องมีการนำเข้า ApiService ที่สร้าง joinActivity ไว้

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  final ActivityService _activityService = ActivityService();
  String _searchQuery = '';
  String? _filterType;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? userId;
  final List<Activity> _activities = [];
  List<Activity> get _filterActivities {
    var q = _searchQuery.trim().toLowerCase();
    return _activities.where((a) {
      final matchQuery =
          q.isEmpty ||
          a.title.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q) ||
          a.tags.join(' ').toLowerCase().contains(q);
      final matchesType = _filterType == null || a.type == _filterType;
      return matchQuery && matchesType;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUserId();
    _fetchActivities();
  }

  Future<void> getUserId() async {
    final token = await SecureStorage.readToken();
    final decoded = JwtDecoder.decode(token!);
    userId = decoded['id'];
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint("Start to fetch data");
      final response = await _activityService.getActivitiesNotJoined(userId!);
      debugPrint("Response: ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        debugPrint("Response data: ${jsonDecode(response.body)['data']}");
        final List data = jsonDecode(response.body)['data'];
        setState(() {
          _activities
            ..clear()
            ..addAll(data.map((e) => Activity.fromJson(e)).toList());
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinActivity(int activityId) async {
    try {
      final response = await _activityService.joinActivity(activityId, userId!);

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final status = responseBody['data']['status'];

        if (status == 'pending' || status == 'accepted') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully joined activity! Status: $status'),
            ),
          );
          setState(() {
            // ลบกิจกรรมที่มี activityId ตรงกับที่ผู้ใช้เข้าร่วม
            _activities.removeWhere((activity) => activity.id == activityId);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to join activity. Status: $status')),
          );
        }
      } else {
        debugPrint("${jsonDecode(response.body)['error']['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join activity. Please try again. '),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error joining activity: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterActivities;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text("Activity Feed"),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // search
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search activities, tags...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            // _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : filtered.isEmpty
                  ? const Center(child: Text("No activities found"))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80, top: 4),
                      itemCount: filtered.length,
                      itemBuilder: (_, idx) =>
                          _buildActivityCard(filtered[idx]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          // ไปหน้า CreateActivityScreen ถ้าต้องการ
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
          );
        },
        label: const Text("Create activity"),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildActivityCard(Activity a) {
    final isFull = a.currentMembers >= a.maxMembers;
    return GestureDetector(
      onTap: () async {
        debugPrint("Creator ID: ${a.creatorId}");
        debugPrint("UserId: $userId");
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActivityDetailScreen(
              activity: a,
              isAdmin: a.creatorId == userId,
              isFull: a.currentMembers >= a.maxMembers,
            ),
          ),
        );
        if (result == true) {
          _fetchActivities();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${a.title} - ${a.isPublic ? "Public" : "Private"}"),
                Text("${a.currentMembers}/${a.maxMembers}"),
              ],
            ),
            Text(a.description),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: a.tags.map((t) => Chip(label: Text(t))).toList(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isFull
                    ? null
                    : () {
                        _joinActivity(a.id);
                      },
                child: Text(isFull ? 'Full' : 'Join'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    // setState(() => _isLoading = true);
    // await Future.delayed(const Duration(seconds: 2));
    await _fetchActivities();
    // setState(() => _isLoading = false);
  }
}
