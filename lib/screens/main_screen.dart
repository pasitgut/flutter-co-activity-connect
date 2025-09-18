import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/screens/activity_feed_screen.dart';
import 'package:flutter_co_activity_connect/screens/auth/login_screen.dart';
import 'package:flutter_co_activity_connect/screens/auth/signin_screen.dart';
import 'package:flutter_co_activity_connect/screens/profile_screen.dart';
import 'package:flutter_co_activity_connect/utils/secure_storage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [ActivityFeedScreen(), ProfileScreen()];
  int _selectedIndex = 0;

  void _onTapped(int idx) {
    setState(() {
      _selectedIndex = idx;
    });
  }

  Future<void> checkAuth() async {
    String? token = await getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => checkAuth());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
