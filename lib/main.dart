import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';
import 'services/background_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await StorageService().init();
  await initializeBackgroundService();

  runApp(const AranApp());
}

class AranApp extends StatelessWidget {
  const AranApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool isComplete = StorageService().isOnboardingComplete;
    
    return MaterialApp(
      title: 'Aran - SOS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundDark,
      ),
      home: isComplete ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
