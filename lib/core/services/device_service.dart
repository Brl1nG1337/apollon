import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceService {
  // Die IP deines Raspberry Pi im lokalen Netzwerk
  final String _baseUrl = 'http://192.168.11.120:8080/api/devices';

  /// Sendet ein neues Gerät an das Spring Boot Backend.
  /// Wirft eine [Exception], falls der Server mit einem Fehlercode antwortet.
  Future<void> createDevice({required String name, required String macAddress}) async {
    final Uri url = Uri.parse(_baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'macAddress': macAddress,
        }),
      );

      // Spring Boot antwortet bei Erfolg mit 201 (CREATED)
      if (response.statusCode != 201 && response.statusCode != 200) {
        // Hier könnte man noch den Error-Body des Backends parsen, falls gewünscht
        throw Exception('Server meldet Fehlercode: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw der Exception, damit das UI weiß, dass etwas schiefgelaufen ist
      throw Exception('Netzwerkfehler: $e');
    }
  }
}