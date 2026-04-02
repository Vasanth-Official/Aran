import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import '../utils/constants.dart';
import '../services/alert_service.dart';
import '../services/storage_service.dart';
import 'sos_trigger_screen.dart';

class KioskLockScreen extends StatefulWidget {
  const KioskLockScreen({super.key});

  @override
  State<KioskLockScreen> createState() => _KioskLockScreenState();
}

class _KioskLockScreenState extends State<KioskLockScreen> {
  final TextEditingController _safeWordController = TextEditingController();
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // Enter full screen and lock phone via kiosk mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    startKioskMode();
  }

  @override
  void dispose() {
    // Exit full screen and unlock kiosk
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    stopKioskMode();
    _safeWordController.dispose();
    super.dispose();
  }

  final AlertService _alertService = AlertService();

  void _verifySafeWord() {
    String actualSafeWord = StorageService().safeWord;
    if (_safeWordController.text.trim().toUpperCase() == actualSafeWord.toUpperCase()) {
      // Unlock success
      _alertService.stopSOS('demo_user_123');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SosTriggerScreen()),
        (route) => false,
      );
    } else {
      // Incorrect safe word
      setState(() {
        _isError = true;
      });
      _safeWordController.clear();
      
      // Reset error state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents back button globally
      child: Scaffold(
        backgroundColor: Colors.black, // Pure black for lock screen
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.primaryRed,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'SOS ACTIVE',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Emergency Contacts Notified\nLive Location Shared',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 60),
                TextField(
                  controller: _safeWordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'ENTER SAFE WORD',
                    hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5), letterSpacing: 2),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _isError ? 'Incorrect Safe Word' : null,
                  ),
                  onSubmitted: (_) => _verifySafeWord(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _verifySafeWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('UNLOCK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
