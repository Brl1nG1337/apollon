import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather/apollon_layered_weather_result.dart';

class ApollonWeatherService {
  final String _apiUrl =
      "https://api.open-meteo.com/v1/forecast?latitude=51.671570&longitude=7.816049&timezone=Europe%2FBerlin&current=temperature_2m,is_day,weather_code&daily=sunrise,sunset,moon_phase&forecast_days=1";

  Future<ApollonLayeredWeatherResult> fetchCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final current = data['current'];
        final int weatherCode = current['weather_code'];
        final bool isDay = current['is_day'] == 1;

        final daily = data['daily'];
        final DateTime sunrise = DateTime.parse(daily['sunrise'][0]);
        final DateTime sunset = DateTime.parse(daily['sunset'][0]);
        final double moonPhaseRaw = daily['moon_phase'][0];
        final DateTime now = DateTime.now();

        final progress = _calculateCelestialProgress(now, sunrise, sunset, isDay);

        // Holt die Wolkenanzahl, den Wolkentyp und das passende Overlay für Ebene 2
        final weather = _mapWmoToWeather(weatherCode);

        final bool showStars = !isDay && weatherCode <= 3;

        return ApollonLayeredWeatherResult(
          isDay: isDay,
          celestialProgress: progress,
          moonPhaseAsset: _getMoonPhaseSvg(moonPhaseRaw),
          showStars: showStars,
          cloudCount: weather.count,
          cloudAssetPath: weather.cloud,
          weatherLayerAsset: weather.overlay,
        );
      } else {
        return _fallbackData();
      }
    } catch (e) {
      return _fallbackData();
    }
  }

  double _calculateCelestialProgress(DateTime now, DateTime sunrise, DateTime sunset, bool isDay) {
    if (isDay) {
      final totalDay = sunset.difference(sunrise).inMinutes;
      final passedDay = now.difference(sunrise).inMinutes;
      if (totalDay <= 0) return 0.5;
      return (passedDay / totalDay).clamp(0.0, 1.0);
    } else {
      if (now.isBefore(sunrise)) {
        final yesterdaySunset = sunset.subtract(const Duration(days: 1));
        final totalNight = sunrise.difference(yesterdaySunset).inMinutes;
        final passedNight = now.difference(yesterdaySunset).inMinutes;
        if (totalNight <= 0) return 0.5;
        return (passedNight / totalNight).clamp(0.0, 1.0);
      } else {
        final tomorrowSunrise = sunrise.add(const Duration(days: 1));
        final totalNight = tomorrowSunrise.difference(sunset).inMinutes;
        final passedNight = now.difference(sunset).inMinutes;
        if (totalNight <= 0) return 0.5;
        return (passedNight / totalNight).clamp(0.0, 1.0);
      }
    }
  }

  /// Mappt den Wettercode auf die genauen Dateinamen aus deinem Screenshot
  ({int count, String? cloud, String? overlay}) _mapWmoToWeather(int code) {
    const base = 'lottie/animated-background/';

    // 0: Klarer Himmel
    if (code == 0) return (count: 0, cloud: null, overlay: null);

    // 1-3: Leicht bis stark bewölkt (weiße Wolken)
    if (code == 1) return (count: 2, cloud: '${base}cloud.json', overlay: null);
    if (code == 2) return (count: 4, cloud: '${base}cloud.json', overlay: null);
    if (code == 3) return (count: 6, cloud: '${base}cloud.json', overlay: null);

    // 45-57: Nebel und Nieselregen (Viele Wolken)
    if (code >= 45 && code <= 57) return (count: 6, cloud: '${base}cloud.json', overlay: null);

    // 61-67 & 80-82: Echter Regen (Dunkle Wolken + Regen-Overlay)
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return (count: 5, cloud: '${base}dark cloud.json', overlay: '${base}rain_overlay.json');
    }

    // 71-77 & 85-86: Schnee (Weiße Wolken + Schnee-Overlay)
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return (count: 5, cloud: '${base}cloud.json', overlay: '${base}snow_overlay.json');
    }

    // 95-99: Gewitter (Dunkle Wolken + Blitz-Overlay)
    if (code >= 95) {
      return (count: 6, cloud: '${base}dark cloud.json', overlay: '${base}dark cloud lightning.json');
    }

    // Fallback
    return (count: 3, cloud: '${base}cloud.json', overlay: null);
  }

  /// Gibt die passenden SVG-Pfade für die Mondphasen zurück
  String _getMoonPhaseSvg(double phase) {
    // TIPP: Passe diesen Pfad an, falls deine SVGs nicht im lottie-Ordner liegen!
    const base = 'assets/svgs/';

    if (phase == 0.0 || phase == 1.0) return '${base}moon_new.svg';
    if (phase > 0.0 && phase < 0.25) return '${base}moon_waxing_crescent.svg';
    if (phase == 0.25) return '${base}moon_first_quarter.svg';
    if (phase > 0.25 && phase < 0.5) return '${base}moon_waxing_gibbous.svg';
    if (phase == 0.5) return '${base}moon_full.svg';
    if (phase > 0.5 && phase < 0.75) return '${base}moon_waning_gibbous.svg';
    if (phase == 0.75) return '${base}moon_last_quarter.svg';

    return '${base}moon_waning_crescent.svg';
  }

  ApollonLayeredWeatherResult _fallbackData() {
    return ApollonLayeredWeatherResult(
      isDay: true,
      celestialProgress: 0.5,
      moonPhaseAsset: 'svg/moon_full.svg',
      showStars: false,
      cloudCount: 3,
      cloudAssetPath: 'lottie/animated-background/cloud.json',
      weatherLayerAsset: null,
    );
  }
}