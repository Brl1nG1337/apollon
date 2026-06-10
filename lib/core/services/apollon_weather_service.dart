import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../models/weather/apollon_layered_weather_result.dart';

class ApollonWeatherService {
  final String _apiUrl =
      "https://api.open-meteo.com/v1/forecast?latitude=51.671570&longitude=7.816049&timezone=Europe%2FBerlin&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,is_day&hourly=temperature_2m,weather_code,precipitation_probability&daily=sunrise,sunset&forecast_days=1";

  Future<ApollonLayeredWeatherResult> fetchCurrentWeather() async {
    final DateTime now = DateTime.now();
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final current = data['current'];
        final double currentTemp = current['temperature_2m'].toDouble();
        final double humidity = current['relative_humidity_2m'].toDouble();
        final double windSpeed = current['wind_speed_10m'].toDouble();
        final int weatherCode = current['weather_code'];
        
        final daily = data['daily'];
        final DateTime sunrise = DateTime.parse(daily['sunrise'][0]);
        final DateTime sunset = DateTime.parse(daily['sunset'][0]);

        // Bestimmung ob Tag ist
        final bool isDay = now.isAfter(sunrise) && now.isBefore(sunset);

        final progress = _calculateCelestialProgress(
          now,
          sunrise,
          sunset,
          isDay,
        );
        final weather = _mapWmoToWeather(weatherCode);

        // Hourly data processing
        final hourly = data['hourly'];
        final List<dynamic> times = hourly['time'];
        final List<dynamic> temps = hourly['temperature_2m'];
        final List<dynamic> codes = hourly['weather_code'];
        final List<dynamic> precipProbs = hourly['precipitation_probability'];

        final List<HourlyForecast> hourlyForecast = [];
        int currentPrecipProb = 0;
        bool foundCurrentPrecip = false;

        for (int i = 0; i < times.length; i++) {
          final time = DateTime.parse(times[i]);

          // Find current/next precipitation probability
          if (!foundCurrentPrecip &&
              time.isAfter(now.subtract(const Duration(hours: 1)))) {
            currentPrecipProb = (precipProbs[i] as num).toInt();
            foundCurrentPrecip = true;
          }

          // Forecast: next 5 items with 3-hour intervals
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
          weatherCode: weatherCode,
          humidity: humidity,
          windSpeed: windSpeed,
          precipitationProbability: currentPrecipProb,
          hourlyForecast: hourlyForecast,
          sunrise: sunrise,
          sunset: sunset,
        );
      } else {
        return _fallbackData();
      }
    } catch (e) {
      return _fallbackData();
    }
  }

  // ==========================================
  // HILFSMETHODEN
  // ==========================================

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
        cloud: '${base}dark_cloud.json',
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
        cloud: '${base}dark_cloud.json',
        overlay: '${base}dark_cloud_lightning.json',
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
      weatherCode: 0,
      humidity: 50.0,
      windSpeed: 10.0,
      precipitationProbability: 0,
      hourlyForecast: [],
      sunrise: DateTime(now.year, now.month, now.day, 6),
      sunset: DateTime(now.year, now.month, now.day, 20),
    );
  }
}
