import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/alert_service.dart';
import 'kiosk_lock_screen.dart';

class SafeWalkScreen extends StatefulWidget {
  const SafeWalkScreen({super.key});

  @override
  State<SafeWalkScreen> createState() => _SafeWalkScreenState();
}

class _SafeWalkScreenState extends State<SafeWalkScreen> {
  int _minutes = 10;
  bool _isActive = false;
  bool _isAlarming = false;
  Timer? _timer;
  int _secondsRemaining = 0;

  final AlertService _alertService = AlertService();

  void _startTimer() {
    setState(() {
      _isActive = true;
      _secondsRemaining = _minutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _triggerCheckInAlarm();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _isAlarming = false;
    });
  }

  void _triggerCheckInAlarm() {
    setState(() => _isAlarming = true);
    
    // Wait 30 seconds for user response
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isAlarming) {
        _alertService.triggerSOS('demo_user_123');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const KioskLockScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeDisplay = '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Safe Walk Timer', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.timer, size: 80, color: AppColors.textMuted),
            const SizedBox(height: 24),
            Text(
              _isActive ? 'Arriving in' : 'Set Estimated Arrival Time',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            if (!_isActive) ...[
              Slider(
                value: _minutes.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                activeColor: AppColors.primaryRed,
                label: '$_minutes mins',
                onChanged: (val) => setState(() => _minutes = val.toInt()),
              ),
              Text('$_minutes Minutes', textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ] else if (!_isAlarming) ...[
              Text(timeDisplay, textAlign: TextAlign.center, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
            ] else ...[
              const Text('ARE YOU SAFE?', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
              const SizedBox(height: 10),
              const Text('SOS triggers in 30 seconds...', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
            const SizedBox(height: 40),
            if (!_isActive)
              ElevatedButton(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('START SAFE WALK', style: TextStyle(fontSize: 18, color: Colors.white)),
              )
            else
              ElevatedButton(
                onPressed: _stopTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isAlarming ? 'I AM SAFE - CANCEL SOS' : 'CANCEL WALK', style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
