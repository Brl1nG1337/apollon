import 'dart:convert';
import 'package:http/http.dart' as http;

enum WeatherCondition { sunny, cloudy, rainy, snowy, stormy }

// Hilfsklasse, um sowohl das Wetter als auch den Tag/Nacht-Status an die AppBar zu liefern
class OpenMeteoResult {
  final WeatherCondition condition;
  final bool isDay;

  OpenMeteoResult({required this.condition, required this.isDay});
}

class WeatherService {
  // Deine exakt konfigurierte Open-Meteo URL
  final String _apiUrl =
      "https://api.open-meteo.com/v1/forecast?latitude=51.68&longitude=7.81&timezone=Europe%2FBerlin&forecast_days=1&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m";

  Future<OpenMeteoResult> fetchCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];

        // 1. Wetter-Code auslesen
        final int weatherCode = current['weather_code'];
        // 2. Is_Day Flag auslesen (1 = Tag, 0 = Nacht)
        final bool isDay = current['is_day'] == 1;

        final condition = _mapWmoCodeToCondition(weatherCode);

        return OpenMeteoResult(condition: condition, isDay: isDay);
      } else {
        print("Open-Meteo Fehler: ${response.statusCode}");
        return OpenMeteoResult(condition: WeatherCondition.cloudy, isDay: true);
      }
    } catch (e) {
      print("Netzwerkfehler bei Open-Meteo: $e");
      return OpenMeteoResult(condition: WeatherCondition.cloudy, isDay: true);
    }
  }

  // Übersetzung der WMO (World Meteorological Organization) Codes
  WeatherCondition _mapWmoCodeToCondition(int code) {
    if (code == 0 || code == 1) return WeatherCondition.sunny; // Klar oder leicht bewölkt
    if (code == 2 || code == 3 || (code >= 45 && code <= 48)) return WeatherCondition.cloudy; // Bewölkt, Nebel
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return WeatherCondition.rainy; // Niesel, Regen, Schauer
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) return WeatherCondition.snowy; // Schnee
    if (code >= 95 && code <= 99) return WeatherCondition.stormy; // Gewitter
    return WeatherCondition.cloudy; // Fallback
  }
}