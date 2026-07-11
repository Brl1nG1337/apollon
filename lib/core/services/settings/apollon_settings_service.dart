import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../apollon_constants.dart';
import '../../models/apollon_setting.dart';
import '../../models/apollon_settings_profile.dart';

class ApollonSettingsService {
  String get baseUrl => '${ApollonConstants.backendBaseUrl}/api/settings';

  ApollonSettingsService();


  /// Holt das Einstellungs-Profil anhand seines Namens (z.B. "Default") vom Backend
  Future<ApollonSettingsProfile> fetchProfile(String profileName) async {
    final url = Uri.parse('$baseUrl/profiles/$profileName');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8 Dekodierung zwingend erforderlich wegen Umlauten (z.B. "Geräte")
        final Map<String, dynamic> decodedJson = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return ApollonSettingsProfile.fromJson(decodedJson);
      } else {
        throw Exception(
          'Fehler beim Laden des Profils. Server antwortete mit Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Netzwerkfehler beim Apollon-API-Aufruf: $e');
    }
  }

  /// Sendet ein aktualisiertes Setting zurück an das Spring Boot Backend
  Future<bool> updateSetting(String profileName, ApollonSetting setting) async {
    final url = Uri.parse(
      '$baseUrl/profiles/$profileName/settings/${setting.key}',
    );

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(setting.toJson()),
      );

      // 200 OK oder 204 No Content sind typische Spring-Erfolgsmeldungen
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // Hier könnte man optional loggen
      return false;
    }
  }
}
