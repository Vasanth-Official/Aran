import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';
import 'sos_trigger_screen.dart';
import 'map_screen.dart';
import 'safe_walk_screen.dart';
import 'rescuer_panel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final Set<String> _notifiedAlerts = {};

  @override
  void initState() {
    super.initState();
    _listenForNearbySOS();
  }

  void _listenForNearbySOS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    Position currentPos = await Geolocator.getCurrentPosition();

    FirebaseDatabase.instance.ref().child('alerts').onChildAdded.listen((event) {
      if (event.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final alertId = event.snapshot.key!;
      
      if (data['status'] == 'ACTIVE' && !_notifiedAlerts.contains(alertId)) {
        // Calculate distance
        double distance = Geolocator.distanceBetween(
          currentPos.latitude, currentPos.longitude,
          data['latitude'], data['longitude']
        );
        
        // If within 5km, alert
        if (distance <= 5000) {
          _notifiedAlerts.add(alertId);
          _showNearbyAlert(alertId, distance);
        }
      }
    });
  }

  void _showNearbyAlert(String alertId, double distance) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryRed.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(color: AppColors.primaryRed.withOpacity(0.2), blurRadius: 30, spreadRadius: -5),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded, color: AppColors.primaryRed, size: 48),
                ),
                const SizedBox(height: 20),
                const Text('NEARBY SOS!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Text(
                  'Someone triggered an SOS ${(distance / 1000).toStringAsFixed(1)}km away from you. They need immediate help.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ignore', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          shadowColor: AppColors.primaryRed.withOpacity(0.5),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RescuerPanelScreen(victimId: alertId)));
                        },
                        child: const Text('Help Them', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
