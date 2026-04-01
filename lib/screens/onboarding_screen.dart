import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _safeWordController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  void _completeOnboarding() async {
    String safeWord = _safeWordController.text.trim();
    String contact = _contactController.text.trim();

    if (safeWord.isEmpty || contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields to ensure protection.')),
      );
      return;
    }

    final storage = StorageService();
    await storage.setSafeWord(safeWord);
    await storage.saveEmergencyContact(contact);
    await storage.setOnboardingComplete();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.security, size: 80, color: AppColors.primaryRed),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Aran',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your personal protection wall. Let\'s set up your core safety features first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
                const SizedBox(height: 48),
                
                const Text('Set a Safe Word', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _safeWordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. ARAN SAFE',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('MANDATORY: You will need this word to turn off an accidental SOS.', style: TextStyle(color: AppColors.primaryRed, fontSize: 12)),
                
                const SizedBox(height: 24),
                const Text('Primary Emergency Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '+1234567890',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ACTIVATE PROTECTION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
