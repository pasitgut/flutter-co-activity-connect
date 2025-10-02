import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';
import 'package:flutter_co_activity_connect/screens/activity/activity_feed_screen.dart';
import 'package:flutter_co_activity_connect/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screenList = [ActivityFeedScreen(), ProfileScreen()];

  int _selectedIndex = 0;

  void _selected(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenList[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Feed",
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: "Friend"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
        onTap: _selected,
        currentIndex: _selectedIndex,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        selectedItemColor: AppColors.primaryColor,
      ),
    );
  }
}
