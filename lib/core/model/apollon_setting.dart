import 'enums/settings/apollon_setting_type.dart';

class ApollonSetting {
  final String id;
  final String key;      // Interner Schlüssel, z.B. "mqtt_retry_interval"
  final String label;    // Anzeige-Name im UI, z.B. "Wiederholungsintervall (s)"
  final dynamic value;   // Kann String, int, double oder bool sein
  final ApollonSettingType type;

  ApollonSetting({
    required this.id,
    required this.key,
    required this.label,
    required this.value,
    required this.type,
  });

  factory ApollonSetting.fromJson(Map<String, dynamic> json) {
    final type = ApollonSettingType.fromString(json['type'] as String);
    dynamic rawValue = json['value'];

    // Sicheres Type-Casting, falls das Backend alles als String schickt
    if (rawValue is String) {
      switch (type) {
        case ApollonSettingType.int:
          rawValue = int.tryParse(rawValue) ?? 0;
          break;
        case ApollonSettingType.double:
          rawValue = double.tryParse(rawValue) ?? 0.0;
          break;
        case ApollonSettingType.boolean:
          rawValue = rawValue.toLowerCase() == 'true';
          break;
        case ApollonSettingType.string:
          break;
      }
    }

    return ApollonSetting(
      id: json['id'].toString(),
      key: json['key'] as String,
      label: json['label'] as String,
      value: rawValue,
      type: type,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'label': label,
    'value': value.toString(), // Oft am sichersten für Spring-Übertragungen
    'type': type.name.toUpperCase(),
  };
}