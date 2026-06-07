import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenMeteoResult {
  final String lottieAssetPath;
  final bool isDay;

  OpenMeteoResult({required this.lottieAssetPath, required this.isDay});
}

class WeatherService {
  final String _apiUrl =
      "https://api.open-meteo.com/v1/forecast?latitude=51.671570&longitude=7.816049&timezone=Europe%2FBerlin&forecast_days=1&current=temperature_2m,is_day,weather_code";

  Future<OpenMeteoResult> fetchCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];

        final int weatherCode = current['weather_code'];
        final bool isDay = current['is_day'] == 1;

        final lottiePath = _mapWmoToLottie(weatherCode, isDay);

        return OpenMeteoResult(lottieAssetPath: lottiePath, isDay: isDay);
      } else {
        return OpenMeteoResult(lottieAssetPath: 'assets/lottie/cloudy day.json', isDay: true);
      }
    } catch (e) {
      return OpenMeteoResult(lottieAssetPath: 'assets/lottie/cloudy day.json', isDay: true);
    }
  }

  String _mapWmoToLottie(int code, bool isDay) {
    const base = 'assets/lottie/';
    final suffix = isDay ? 'day.json' : 'night.json';

    // 1. Klarer Himmel (WMO 0)
    if (code == 0) {
      return '${base}clear $suffix';
    }

    // 2. ALLES von WMO 1 bis unter 61 wird zu "cloudy"
    // Das fängt alle Wolken-, Nebel- und Nieselregen-Codes (51, 53, 55, 56, 57) ab!
    if (code <= 61) {
      return '${base}cloudy $suffix';
    }

    // 3. Echter Regen (WMO 61 bis 67 und die Regenschauer 80 bis 82)
    if ((code > 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return '${base}rainy $suffix';
    }

    // 4. Schnee (WMO 71 bis 77 und 85, 86)
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return '${base}snow $suffix';
    }

    // 5. Gewitter (WMO 95 bis 99)
    if (code >= 95) {
      return '${base}stormy $suffix';
    }

    // Extrem unwahrscheinlicher Fallback
    return '${base}cloudy $suffix';
  }
}