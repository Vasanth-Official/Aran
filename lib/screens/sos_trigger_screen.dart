import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sensor_service.dart';
import '../utils/constants.dart';
import '../services/alert_service.dart';
import 'kiosk_lock_screen.dart';

class SosTriggerScreen extends StatefulWidget {
  const SosTriggerScreen({super.key});

  @override
  State<SosTriggerScreen> createState() => _SosTriggerScreenState();
}

class _SosTriggerScreenState extends State<SosTriggerScreen> with SingleTickerProviderStateMixin {
  final SensorService _sensorService = SensorService();
  bool _isHolding = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Start listening to shake
    _sensorService.startShakeDetection(_triggerSos);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        _triggerSos();
        _animationController.reset();
        setState(() => _isHolding = false);
      }
    });
  }

  @override
  void dispose() {
    _sensorService.stopShakeDetection();
    _animationController.dispose();
    super.dispose();
  }

  final AlertService _alertService = AlertService();

  void _triggerSos() {
    _alertService.triggerSOS('demo_user_123'); // Demo user id
    // Navigate to Kiosk Lock Screen uniquely and clear stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const KioskLockScreen()),
      (route) => false,
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isHolding = true);
    _animationController.forward();
  }

  void _onPointerUp(PointerUpEvent? event) {
    if (_isHolding) {
      setState(() => _isHolding = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Aran Protection', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 80, color: AppColors.textMuted),
            const SizedBox(height: 20),
            const Text(
              'Hold button for 2 seconds\nor shake phone to trigger SOS',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 18),
            ),
            const SizedBox(height: 60),
            Listener(
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerUp,
              onPointerCancel: (_) => _onPointerUp(null),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: _animationController.value,
                          color: AppColors.primaryRed,
                          strokeWidth: 8,
                          backgroundColor: AppColors.surfaceDark,
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: _isHolding ? AppColors.primaryRed.withValues(alpha: 0.8) : AppColors.primaryRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
