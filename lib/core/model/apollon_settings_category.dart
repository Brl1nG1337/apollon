import 'apollon_setting.dart';

class ApollonSettingsCategory {
  final String id;
  final String name;       // z.B. "MQTT Konfiguration"
  final String? iconName;  // Für das UI-Mapping (z.B. "cloud", "router")
  final List<ApollonSetting> settings;

  ApollonSettingsCategory({
    required this.id,
    required this.name,
    this.iconName,
    required this.settings,
  });

  factory ApollonSettingsCategory.fromJson(Map<String, dynamic> json) {
    return ApollonSettingsCategory(
      id: json['id'].toString(),
      name: json['name'] as String,
      iconName: json['iconName'] as String?,
      settings: (json['settings'] as List<dynamic>?)
          ?.map((e) => ApollonSetting.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconName': iconName,
    'settings': settings.map((e) => e.toJson()).toList(),
  };
}