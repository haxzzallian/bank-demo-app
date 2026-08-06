import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  OnboardingStorage._();

  static final OnboardingStorage instance = OnboardingStorage._();
  static const String _completedKey = 'onboarding_completed';

  Future<bool> hasCompletedOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_completedKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_completedKey, true);
  }
}
