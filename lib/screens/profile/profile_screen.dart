import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/model/activity.dart';
import 'package:flutter_co_activity_connect/screens/profile/edit_profile_screen.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:flutter_co_activity_connect/screens/activity/activity_details_screen.dart';
import 'package:flutter_co_activity_connect/screens/auth/check_auth_screen.dart';
import 'package:flutter_co_activity_connect/services/activity_service.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ActivityService _activityService = ActivityService();
  bool _isLoading = false;
  List<Activity> _joinedActivities = [];
  List<Activity> _pendingActivities = [];
  Map<String, dynamic>? _profileData;
  String? userId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ refresh เมื่อเปลี่ยน tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        _fetchProfileAndActivities();
      }
    });

    _fetchProfileAndActivities();
  }

  Future<void> _fetchProfileAndActivities() async {
    setState(() => _isLoading = true);
    try {
      final token = await SecureStorage.readToken();
      if (token == null) return;

      final decoded = JwtDecoder.decode(token);
      userId = decoded['id'];

      _profileData = {
        'avatarUrl':
            decoded['avatar'] ??
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png',
        'name': decoded['username'] ?? 'Username',
        'email': decoded['email'] ?? 'username@kkumail.com',
        'faculty': decoded['faculty'] ?? "faculty",
        'major': decoded['major'] ?? "major",
        'year': decoded['year'] ?? "year",
        'bio': decoded['bio'] ?? "",
      };

      // Fetch Joined Activities
      final responseJoined = await _activityService.getActivitiesJoined(
        userId!,
      );
      if (responseJoined.statusCode == 200) {
        final data = jsonDecode(responseJoined.body)['data'] as List;
        _joinedActivities = data.map((e) => Activity.fromJson(e)).toList();
      }

      // Fetch Pending Activities
      final responsePending = await _activityService.getActivitiesPending(
        userId!,
      );
      if (responsePending.statusCode == 200) {
        final data = jsonDecode(responsePending.body)['data'] as List;
        _pendingActivities = data.map((e) => Activity.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CheckAuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Joined'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : _profileData == null
            ? const Center(child: Text("No profile data"))
            : Column(
                children: [
                  _buildProfileCard(theme),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildActivityList(_joinedActivities),
                        _buildActivityList(_pendingActivities),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(_profileData!['avatarUrl']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileData!['name'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profileData!['email'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${_profileData!['faculty']} - ${_profileData!['major']}",
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text("${_profileData!['year']}"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_profileData!['bio']),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              debugPrint("Update Result: $result");
              if (result == true) {
                _fetchProfileAndActivities();
              }
            },
            child: const Text("Edit Profile"),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<Activity> activities) {
    if (activities.isEmpty) {
      return const Center(child: Text("No activities found"));
    }

    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return _buildActivityCard(activities[index]);
      },
    );
  }

  Widget _buildActivityCard(Activity a) {
    return GestureDetector(
      onTap: () async {
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
          _fetchProfileAndActivities();
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
          ],
        ),
      ),
    );
  }
}
