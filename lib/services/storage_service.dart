import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isOnboardingComplete => _prefs?.getBool('onboarding_complete') ?? false;
  Future<void> setOnboardingComplete() async => await _prefs?.setBool('onboarding_complete', true);

  String get safeWord => _prefs?.getString('safe_word') ?? "ARAN SAFE";
  Future<void> setSafeWord(String word) async => await _prefs?.setString('safe_word', word);

  List<String> get emergencyContacts => _prefs?.getStringList('emergency_contacts') ?? [];
  Future<void> saveEmergencyContact(String contact) async {
    final contacts = emergencyContacts;
    if (!contacts.contains(contact)) {
      contacts.add(contact);
      await _prefs?.setStringList('emergency_contacts', contacts);
    }
  }
}
