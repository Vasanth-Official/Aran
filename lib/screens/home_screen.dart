import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'sos_trigger_screen.dart';
import 'map_screen.dart';
import 'safe_walk_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SosTriggerScreen(),
    const MapScreen(),
    const SafeWalkScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'SOS'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Danger Map'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Safe Walk'),
        ],
      ),
    );
  }
}
