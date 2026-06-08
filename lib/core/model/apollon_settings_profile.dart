import 'apollon_settings_category.dart';

class ApollonSettingsProfile {
  final String id;
  final String name; // z.B. "Default" oder "Developer"
  final List<ApollonSettingsCategory> categories;

  ApollonSettingsProfile({
    required this.id,
    required this.name,
    required this.categories,
  });

  factory ApollonSettingsProfile.fromJson(Map<String, dynamic> json) {
    return ApollonSettingsProfile(
      id: json['id'].toString(),
      name: json['name'] as String,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => ApollonSettingsCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categories': categories.map((e) => e.toJson()).toList(),
  };
}