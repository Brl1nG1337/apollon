import '../../model/apollon_settings_profile.dart';

class ApollonSettingsManager {
  // Singleton-Muster: Es gibt app-weit immer nur eine Instanz
  static final ApollonSettingsManager _instance = ApollonSettingsManager._internal();
  factory ApollonSettingsManager() => _instance;
  ApollonSettingsManager._internal();

  // Hier wird das Profil abgelegt, sobald es vom Backend kommt
  ApollonSettingsProfile? currentProfile;

  // Hilfsmethode, um schnell an ein bestimmtes Setting zu kommen
  dynamic getSettingValue(String categoryName, String settingKey) {
    try {
      final category = currentProfile?.categories.firstWhere((c) => c.name == categoryName);
      final setting = category?.settings.firstWhere((s) => s.key == settingKey);
      return setting?.value;
    } catch (_) {
      return null; // Falls Kategorie oder Key nicht existieren
    }
  }
}