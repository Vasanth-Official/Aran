import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription? _accelerometerSubscription;
  final double shakeThresholdGravity = 2.7; // ~2.7G
  int _shakeCount = 0;
  DateTime _lastShakeTime = DateTime.now();

  void startShakeDetection(Function onShake) {
    _accelerometerSubscription = userAccelerometerEventStream(samplingPeriod: const Duration(milliseconds: 50)).listen((UserAccelerometerEvent event) {
      double gX = event.x / 9.80665;
      double gY = event.y / 9.80665;
      double gZ = event.z / 9.80665;

      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > shakeThresholdGravity) {
        final now = DateTime.now();
        if (_lastShakeTime.add(const Duration(milliseconds: 500)).isAfter(now)) {
          return;
        }
        
        _shakeCount++;
        _lastShakeTime = now;

        if (_shakeCount >= 3) {
          _shakeCount = 0;
          onShake();
        }
      } else {
        // Reset shake count if too much time passes between shakes
        final now = DateTime.now();
        if (_lastShakeTime.add(const Duration(seconds: 2)).isBefore(now)) {
          _shakeCount = 0;
        }
      }
    });
  }

  void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
  }
}
