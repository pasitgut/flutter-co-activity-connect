import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/models/activity.dart';
import 'package:flutter_co_activity_connect/screens/activity_detail_screen.dart';
import 'package:flutter_co_activity_connect/screens/create_activity_screen.dart';
import 'package:flutter_co_activity_connect/utils/routes.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  String _searchQuery = '';
  String? _filterType;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  final List<Activity> _activities = [
    Activity(
      id: 'a1',
      name: 'ติวคณิต ม.4-ม.6',
      description: 'ติวเข้มก่อนสอบปลายภาค ทุกวันเสาร์ 9:00-12:00',
      imageUrl: 'https://placehold.co/600x400.png',
      type: 'Study Group',
      tags: ['Math', 'Exam'],
      joinCondition: 'นักศึกษาคณะวิทย์เท่านั้น',
      maxMembers: 20,
      currentMembers: 5,
    ),
    Activity(
      id: 'a2',
      name: 'ทีมฟุตบอลคณะ',
      description: 'ซ้อมทุกพุธเย็น สนใจลองมาร่วมซ้อมได้',
      imageUrl: 'https://placehold.co/600x400.png',
      type: 'Sports',
      tags: ['Football', 'Weekend'],
      joinCondition: '',
      maxMembers: 22,
      currentMembers: 11,
    ),
    Activity(
      id: 'a2',
      name: 'ทีมฟุตบอลคณะ',
      description: 'ซ้อมทุกพุธเย็น สนใจลองมาร่วมซ้อมได้',
      imageUrl: 'https://placehold.co/600x400.png',
      type: 'Football',
      tags: ['Football', 'Weekend'],
      joinCondition: '',
      maxMembers: 22,
      currentMembers: 11,
    ),
    Activity(
      id: 'a2',
      name: 'ทีมฟุตบอลคณะ',
      description: 'ซ้อมทุกพุธเย็น สนใจลองมาร่วมซ้อมได้',
      imageUrl: 'https://placehold.co/600x400.png',
      type: 'Game',
      tags: ['Football', 'Weekend'],
      joinCondition: '',
      maxMembers: 22,
      currentMembers: 11,
    ),
  ];

  List<Activity> get _filteredActivities {
    var list = _activities.where((a) {
      final q = _searchQuery.trim().toLowerCase();
      final matchQuery =
          q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q) ||
          a.tags.join(' ').toLowerCase().contains(q);
      final matchesType = _filterType == null || a.type == _filterType;
      return matchQuery && matchesType;
    }).toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredActivities;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const Text("Activity Feed"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search activities, tags...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                }),
              ),
            ),

            // Filter chips
            Align(alignment: Alignment.topLeft, child: _buildFilterChips()),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 80),
                          Center(child: Text("No activities found")),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 4),
                        itemCount: filtered.length,
                        itemBuilder: (_, idx) {
                          return _buildActivityCard(filtered[idx]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.push(context, createRoute(CreateActivityScreen())),
        child: Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildFilterChips() {
    final types = <String>{'All', ..._activities.map((e) => e.type)};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: types.map((t) {
          final isAll = t == 'All';
          final selected = isAll ? _filterType == null : _filterType == t;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(t),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _filterType = isAll ? null : t;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityCard(Activity a) {
    final isFull = a.currentMembers >= a.maxMembers;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          createRoute(ActivityDetailScreen(activity: a)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  a.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: a.tags
                              .map(
                                (t) => Chip(
                                  label: Text(t),
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text('${a.currentMembers}/${a.maxMembers}'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: isFull
                            ? null
                            : () {
                                setState(() {
                                  a.currentMembers = (a.currentMembers + 1)
                                      .clamp(0, a.maxMembers);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Joined "${a.name}"')),
                                );
                              },
                        child: Text(isFull ? 'Full' : 'Join'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
