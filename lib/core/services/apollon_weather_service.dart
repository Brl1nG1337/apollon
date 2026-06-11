import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../models/weather/apollon_layered_weather_result.dart';

class ApollonWeatherService {
  // Koordinaten für Hamm NRW Mitte
  static const double lat = 51.671570;
  static const double lon = 7.816049;

  final String _openMeteoUrl =
      "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&timezone=Europe%2FBerlin&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,is_day&hourly=temperature_2m,weather_code,precipitation_probability&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&forecast_days=7";

  final String _brightSkyUrl =
      "https://api.brightsky.dev/current_weather?lat=$lat&lon=$lon";

  Future<ApollonLayeredWeatherResult> fetchCurrentWeather() async {
    final DateTime now = DateTime.now();
    try {
      // Beide APIs parallel abfragen
      final results = await Future.wait([
        http.get(Uri.parse(_openMeteoUrl)),
        http.get(Uri.parse(_brightSkyUrl)),
      ]);

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final openMeteoData = jsonDecode(results[0].body);
        final brightSkyData = jsonDecode(results[1].body)['weather'];

        // --- Daten von Open-Meteo (Basis & Forecast) ---
        final currentOM = openMeteoData['current'];
        final double humidity = currentOM['relative_humidity_2m'].toDouble();
        final double windSpeed = currentOM['wind_speed_10m'].toDouble();
        final double apparentTempOM = currentOM['apparent_temperature'].toDouble();
        
        final daily = openMeteoData['daily'];
        final DateTime sunrise = DateTime.parse(daily['sunrise'][0]);
        final DateTime sunset = DateTime.parse(daily['sunset'][0]);
        final double dailyMax = daily['temperature_2m_max'][0].toDouble();
        final double dailyMin = daily['temperature_2m_min'][0].toDouble();

        // --- Daten von Bright Sky (Aktuelle Präzision) ---
        // Wir nutzen Bright Sky für die Temperatur und den Wetter-Zustand (Icon)
        final double currentTemp = (brightSkyData['temperature'] as num).toDouble();
        final String bsIcon = brightSkyData['icon'];
        final int weatherCode = _mapBrightSkyIconToWmo(bsIcon);
        // Bright Sky apparent_temperature nutzen falls vorhanden, sonst Fallback auf OM
        final double apparentTemp = (brightSkyData['apparent_temperature'] ?? apparentTempOM).toDouble();

        // Bestimmung ob Tag ist
        final bool isDay = now.isAfter(sunrise) && now.isBefore(sunset);

        final progress = _calculateCelestialProgress(
          now,
          sunrise,
          sunset,
          isDay,
        );
        
        // Hintergrund-Logik basierend auf dem präzisen Bright Sky Code
        final weather = _mapWmoToWeather(weatherCode);

        // Daily forecast (bleibt Open-Meteo)
        final List<DailyForecast> dailyForecast = [];
        final List<dynamic> dailyDates = daily['time'];
        final List<dynamic> dailyCodes = daily['weather_code'];
        final List<dynamic> dailyMaxes = daily['temperature_2m_max'];
        final List<dynamic> dailyMines = daily['temperature_2m_min'];

        for (int i = 0; i < dailyDates.length; i++) {
          dailyForecast.add(DailyForecast(
            date: DateTime.parse(dailyDates[i]),
            weatherCode: dailyCodes[i],
            maxTemp: dailyMaxes[i].toDouble(),
            minTemp: dailyMines[i].toDouble(),
          ));
        }

        // Hourly data processing (bleibt Open-Meteo)
        final hourly = openMeteoData['hourly'];
        final List<dynamic> times = hourly['time'];
        final List<dynamic> temps = hourly['temperature_2m'];
        final List<dynamic> codes = hourly['weather_code'];
        final List<dynamic> precipProbs = hourly['precipitation_probability'];

        final List<HourlyForecast> hourlyForecast = [];
        int currentPrecipProb = 0;
        bool foundCurrentPrecip = false;

        for (int i = 0; i < times.length; i++) {
          final time = DateTime.parse(times[i]);

          if (!foundCurrentPrecip &&
              time.isAfter(now.subtract(const Duration(hours: 1)))) {
            currentPrecipProb = (precipProbs[i] as num).toInt();
            foundCurrentPrecip = true;
          }

          if (time.isAfter(now)) {
            if (hourlyForecast.isEmpty ||
                time.difference(hourlyForecast.last.time).inHours >= 3) {
              if (hourlyForecast.length < 5) {
                hourlyForecast.add(
                  HourlyForecast(
                    time: time,
                    weatherCode: codes[i],
                    temperature: temps[i].toDouble(),
                  ),
                );
              }
            }
          }
        }

        final double moonPhaseRaw = _calculateMoonPhase(now);
        final bool showStars = !isDay && weatherCode <= 3;

        return ApollonLayeredWeatherResult(
          isDay: isDay,
          celestialProgress: progress,
          moonPhaseAsset: _getMoonPhaseSvg(moonPhaseRaw),
          showStars: showStars,
          cloudCount: weather.count,
          cloudAssetPath: weather.cloud,
          weatherLayerAsset: weather.overlay,
          currentTemp: currentTemp,
          apparentTemp: apparentTemp,
          weatherCode: weatherCode,
          humidity: humidity,
          windSpeed: windSpeed,
          precipitationProbability: currentPrecipProb,
          dailyMax: dailyMax,
          dailyMin: dailyMin,
          hourlyForecast: hourlyForecast,
          dailyForecast: dailyForecast,
          sunrise: sunrise,
          sunset: sunset,
        );
      } else {
        return _fallbackData();
      }
    } catch (e) {
      print("Error fetching combined weather data: $e");
      return _fallbackData();
    }
  }

  // ==========================================
  // HILFSMETHODEN
  // ==========================================

  int _mapBrightSkyIconToWmo(String icon) {
    switch (icon) {
      case 'clear-day':
      case 'clear-night':
        return 0;
      case 'partly-cloudy-day':
      case 'partly-cloudy-night':
        return 2;
      case 'cloudy':
        return 3;
      case 'fog':
        return 45;
      case 'rain':
        return 61;
      case 'sleet':
        return 66;
      case 'snow':
        return 71;
      case 'thunderstorm':
        return 95;
      default:
        return 0;
    }
  }

  double _calculateMoonPhase(DateTime date) {
    final newMoon = DateTime.utc(2024, 1, 11, 11, 57);
    const lunarCycleMinutes = 29.530588 * 24 * 60;

    final difference = date.difference(newMoon).inMinutes;
    double phase = (difference / lunarCycleMinutes) % 1.0;

    if (phase < 0) phase += 1.0;
    return phase;
  }

  double _calculateCelestialProgress(
    DateTime now,
    DateTime sunrise,
    DateTime sunset,
    bool isDay,
  ) {
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

  ({int count, String? cloud, String? overlay}) _mapWmoToWeather(int code) {
    const base = 'assets/lottie/';

    if (code == 0) return (count: 0, cloud: null, overlay: null);
    if (code == 1) return (count: 2, cloud: '${base}cloud.json', overlay: null);
    if (code == 2) return (count: 4, cloud: '${base}cloud.json', overlay: null);
    if (code == 3) return (count: 6, cloud: '${base}cloud.json', overlay: null);
    if (code >= 45 && code <= 57)
      return (count: 6, cloud: '${base}cloud.json', overlay: null);
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82))
      return (
        count: 5,
        cloud: '${base}cloud.json',
        overlay: '${base}rain_overlay.json',
      );
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86))
      return (
        count: 5,
        cloud: '${base}cloud.json',
        overlay: '${base}snow_overlay.json',
      );
    if (code >= 95)
      return (
        count: 6,
        cloud: '${base}dark_cloud_lightning.json',
        overlay: '${base}rain_overlay.json',
      );

    return (count: 3, cloud: '${base}cloud.json', overlay: null);
  }

  String _getMoonPhaseSvg(double phase) {
    const base = 'assets/svgs/';

    if (phase < 0.03 || phase > 0.97) return '${base}moon_new.svg';
    if (phase < 0.22) return '${base}moon_waxing_crescent.svg';
    if (phase < 0.28) return '${base}moon_first_quarter.svg';
    if (phase < 0.47) return '${base}moon_waxing_gibbous.svg';
    if (phase < 0.53) return '${base}moon_full.svg';
    if (phase < 0.72) return '${base}moon_waning_gibbous.svg';
    if (phase < 0.78) return '${base}moon_last_quarter.svg';

    return '${base}moon_waning_crescent.svg';
  }

  ApollonLayeredWeatherResult _fallbackData() {
    final now = DateTime.now();
    return ApollonLayeredWeatherResult(
      isDay: now.hour > 6 && now.hour < 20,
      celestialProgress: 0.5,
      moonPhaseAsset: 'assets/svgs/moon_full.svg',
      showStars: false,
      cloudCount: 3,
      cloudAssetPath: 'assets/lottie/animated-background/cloud.json',
      weatherLayerAsset: null,
      currentTemp: 20.0,
      apparentTemp: 19.0,
      weatherCode: 0,
      humidity: 50.0,
      windSpeed: 10.0,
      precipitationProbability: 0,
      dailyMax: 22.0,
      dailyMin: 15.0,
      hourlyForecast: [],
      dailyForecast: [],
      sunrise: DateTime(now.year, now.month, now.day, 6),
      sunset: DateTime(now.year, now.month, now.day, 20),
    );
  }
}
