import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import '../firebase_options.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'aran_sos_channel',
    'SOS Alerts',
    description: 'Notifications for nearby SOS alerts',
    importance: Importance.max,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'aran_sos_channel',
      initialNotificationTitle: 'Aran Monitoring',
      initialNotificationContent: 'Looking out for nearby SOS alerts',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final Set<String> notifiedAlerts = {};
  final AudioPlayer audioPlayer = AudioPlayer();

  FirebaseDatabase.instance.ref().child('alerts').onChildAdded.listen((event) async {
    if (event.snapshot.value == null) return;

    final data = Map<String, dynamic>.from(event.snapshot.value as Map);
    final alertId = event.snapshot.key!;

    if (data['status'] == 'ACTIVE' && !notifiedAlerts.contains(alertId)) {
      try {
        Position currentPos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        double distance = Geolocator.distanceBetween(
          currentPos.latitude,
          currentPos.longitude,
          data['latitude'],
          data['longitude'],
        );

        if (distance <= 5000) {
          notifiedAlerts.add(alertId);

          // Vibrate and Play Audio Loudly continuously or once
          audioPlayer.setReleaseMode(ReleaseMode.loop);
          await audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/alarms/bugle_tune.ogg'));

          await flutterLocalNotificationsPlugin.show(
            alertId.hashCode,
            '🚨 NEARBY SOS ALERT! 🚨',
            'Someone triggered an SOS ${(distance / 1000).toStringAsFixed(1)}km away from you. Tap to help!',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'aran_sos_channel',
                'SOS Alerts',
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                fullScreenIntent: true,
                playSound: true,
                enableVibration: true,
              ),
            ),
          );
        }
      } catch (e) {
        // Handle error securely in background
      }
    }
  });

  // Also listen for REMOTE SIREN for our own alerts if necessary?
  // AlertService normally handles it on the victim's phone. 
  // We'll leave the victim-side siren listening to `AlertService.dart`.

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    audioPlayer.stop();
    service.stopSelf();
  });
}
