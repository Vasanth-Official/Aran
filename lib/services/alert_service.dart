import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'storage_service.dart';

class AlertService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final Telephony _telephony = Telephony.instance;
  StreamSubscription<Position>? _positionStream;

  Future<void> triggerSOS(String userId) async {
    // 1. Get permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // 2. Start Live Location Tracking
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      // Update Firebase RTDB
      _dbRef.child('alerts').child(userId).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'ACTIVE',
      });
    });

    // 3. Send SMS to emergency contacts fallback
    List<String> emergencyContacts = StorageService().emergencyContacts;
    if (emergencyContacts.isEmpty) emergencyContacts = ["+1234567890"];

    for (String contact in emergencyContacts) {
      try {
        await _telephony.sendSms(
          to: contact,
          message: "SOS! I need help. I have triggered the Aran Protection app. My live location is being tracked.",
        );
      } catch (e) {
        // Log Error or silently fail
      }
    }
  }

  void stopSOS(String userId) {
    _positionStream?.cancel();
    _dbRef.child('alerts').child(userId).update({
      'status': 'RESOLVED',
    });
  }
}
