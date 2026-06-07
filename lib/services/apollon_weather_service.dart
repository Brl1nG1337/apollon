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

    // 1. Klarer Himmel
    if (code == 0) {
      return '${base}clear $suffix';
    }

    // 2. Bewölkt / Nebel / Sehr leichter Nieselregen
    // WMO 51, 53 = Leichter/Mäßiger Nieselregen -> Zeige hier lieber noch "cloudy"
    if (code >= 1 && code <= 48 || code == 51 || code == 53) {
      return '${base}cloudy $suffix';
    }

    // 3. Echter Regen (Starker Niesel, mäßiger bis starker Regen & Schauer)
    // WMO 55 = Dichter Nieselregen, 61-67 = Regen, 80-82 = Regenschauer
    if (code == 55 || (code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return '${base}rainy $suffix';
    }

    // 4. Schnee
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return '${base}snow $suffix';
    }

    // 5. Gewitter
    if (code >= 95) {
      return '${base}stormy $suffix';
    }

    return '${base}cloudy $suffix';
  }
}