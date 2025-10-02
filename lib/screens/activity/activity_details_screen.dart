import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/screens/activity/edit_activity_screen.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:flutter_co_activity_connect/screens/group_chat_screen.dart';
import 'package:flutter_co_activity_connect/services/activity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_co_activity_connect/model/activity.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_co_activity_connect/model/activity_member.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final Activity activity;
  final bool isAdmin;
  final bool isFull;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
    this.isAdmin = false,
    this.isFull = false,
  });

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  final ActivityService _activityService = ActivityService();
  bool _joined = false;
  String? userId;
  bool _isLoading = false;
  List<ActivityMember> _acceptedMembers = [];
  List<ActivityMember> _pendingMembers = [];

  // ฟังก์ชันดึง userId จาก token
  Future<void> getUserId() async {
    final token = await SecureStorage.readToken();
    final decoded = JwtDecoder.decode(token!);
    userId = decoded['id'];
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUserId();
    await _fetchMembers();
    _checkIfJoined();
  }

  // ฟังก์ชัน join activity
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
          Navigator.pop(context, true); // กลับไปพร้อมส่ง true
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to join activity. Status: $status')),
          );
        }
      } else {
        debugPrint("${jsonDecode(response.body)['error']['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join activity. Please try again.')),
        );
      }
    } catch (e) {
      debugPrint("Error joining activity: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ฟังก์ชันดึงสมาชิกของกิจกรรม
  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _activityService.getActivityMembers(
        widget.activity.id,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        debugPrint("Data: $data");
        setState(() {
          // แยกสมาชิกตาม status เป็น 'accepted' และ 'pending'
          _acceptedMembers = data
              .where((e) => e['status'] == 'accepted')
              .map((e) => ActivityMember.fromJson(e))
              .toList();

          _pendingMembers = data
              .where((e) => e['status'] == 'pending')
              .map((e) => ActivityMember.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching members: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkIfJoined() {
    if (userId != null && _acceptedMembers.isNotEmpty) {
      setState(() {
        _joined = _acceptedMembers.any((member) {
          debugPrint("Member: ${member.userId} : ${member.userId == userId}");
          return member.userId == userId && member.status == 'accepted';
        });
      });
    } else {
      debugPrint("Error to check joined.");
    }
  }

  // ฟังก์ชันที่จะทำการ Reject user
  Future<void> _rejectUser(String targetId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _activityService.rejectUser(
        widget.activity.id,
        targetId,
      );

      if (response.statusCode == 200) {
        setState(() {
          _acceptedMembers.removeWhere((m) => m.userId == targetId);
          _pendingMembers.removeWhere((m) => m.userId == targetId);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User has been removed.')));
        if (targetId == userId) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove user.')));
      }
    } catch (e) {
      debugPrint("Error rejecting user: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ฟังก์ชันที่จะทำการ Accept user
  Future<void> _acceptUser(ActivityMember m) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _activityService.updateJoinRequest(
        widget.activity.id,
        'accepted',
        m.userId,
      );

      if (response.statusCode == 200) {
        setState(() {
          _pendingMembers.removeWhere((mr) => mr.userId == m.userId);
          _acceptedMembers.add(m);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User has been accepted.')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to accept user.')));
      }
    } catch (e) {
      debugPrint("Error accepting user: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _reject(String targetId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _activityService.updateJoinRequest(
        widget.activity.id,
        'rejected',
        targetId,
      );

      if (response.statusCode == 200) {
        setState(() {
          _acceptedMembers.removeWhere((m) => m.userId == targetId);
          _pendingMembers.removeWhere((m) => m.userId == targetId);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User has been rejected.')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to reject user.')));
      }
    } catch (e) {
      debugPrint("Error rejecting user: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var a = widget.activity;
    return Scaffold(
      appBar: AppBar(
        title: Text(a.title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit activity',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditActivityScreen(activity: a),
                  ),
                );

                if (result != null) {
                  setState(() {
                    a.title = result['title'];
                    a.description = result['description'];
                    a.maxMembers = result['maxMembers'];
                    a.isPublic = result['isPublic'];
                    a.tags = List<String>.from(result['tags']);
                  });
                }
              },
            ),
          if (_joined && !widget.isAdmin)
            IconButton(
              onPressed: () => _rejectUser(userId!),
              icon: Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(a.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text("${a.currentMembers}/${a.maxMembers} members"),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: a.tags.map((t) => Chip(label: Text(t))).toList(),
          ),
          const SizedBox(height: 20),
          if (a.isPublic || _joined) ...[
            const Text(
              "Accepted Members",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _acceptedMembers.isEmpty
                ? const Text("No accepted members yet.")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _acceptedMembers.length,
                    itemBuilder: (context, idx) {
                      final member = _acceptedMembers[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(member.avatarUrl),
                        ),
                        title: Text(member.username),
                        subtitle: Text(member.role),
                        trailing: widget.isAdmin && member.userId != userId
                            ? IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () => _rejectUser(member.userId),
                              )
                            : null,
                      );
                    },
                  ),
            const SizedBox(height: 20),
            if (widget.isAdmin) ...[
              const Text(
                "Pending Members",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _pendingMembers.isEmpty
                  ? const Text("No pending members yet.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pendingMembers.length,
                      itemBuilder: (context, idx) {
                        final member = _pendingMembers[idx];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(member.avatarUrl),
                          ),
                          title: Text(member.username),
                          subtitle: Text(member.role),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                onPressed: () => _acceptUser(member),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () => _reject(member.userId),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ],
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: _joined
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryColor,
              heroTag: 'chatBtn',
              onPressed: () async {
                final token = await SecureStorage.readToken();
                final decoded = JwtDecoder.decode(token!);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupChatScreen(
                      activityId: a.id,
                      currentUserId: decoded['id'],
                      activityName: a.title,
                    ),
                  ),
                );
              },
              label: const Text(
                'Group Chat',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            )
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primaryColor,
              heroTag: 'joinBtn',
              onPressed: widget.isFull
                  ? null
                  : () => _joinActivity(widget.activity.id),
              label: widget.isFull
                  ? const Text('Full', style: TextStyle(color: Colors.white))
                  : const Text(
                      'Request to Join',
                      style: TextStyle(color: Colors.white),
                    ),
              icon: widget.isFull
                  ? null
                  : const Icon(Icons.group_add, color: Colors.white),
            ),
      floatingActionButtonLocation: _joined
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
    );
  }
}
