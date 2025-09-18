import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/models/activity.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final isFull = activity.currentMembers >= activity.maxMembers;
    return Scaffold(
      appBar: AppBar(title: Text(activity.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.imageUrl != null)
              Image.network(
                activity.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity.type,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(activity.description),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: activity.tags
                        .map((t) => Chip(label: Text(t)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Join condition: ${activity.joinCondition.isEmpty ? 'None' : activity.joinCondition}',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Members: ${activity.currentMembers}/${activity.maxMembers}',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isFull
                          ? null
                          : () {
                              // In a real app you would call backend to join
                              // For demo we just show a snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Requested to join "${activity.name}"',
                                  ),
                                ),
                              );
                            },
                      child: Text(isFull ? 'Full' : 'Request to Join'),
                    ),
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
