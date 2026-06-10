import 'dart:math';

import 'package:apollon/core/models/weather/apollon_celestial_position.dart';

class HourlyForecast {
  final DateTime time;
  final int weatherCode;
  final double temperature;

  HourlyForecast({
    required this.time,
    required this.weatherCode,
    required this.temperature,
  });
}

class ApollonLayeredWeatherResult {
  final bool isDay;
  final double celestialProgress;
  final String moonPhaseAsset;
  final bool showStars;

  // --- NEU: Wolken & Wetter ---
  final int cloudCount; // 0 bis z.B. 6
  final String? cloudAssetPath; // cloud.json oder dark cloud.json
  final String?
      weatherLayerAsset; // rain_overlay, snow_overlay, dark cloud lightning

  // --- NEU für Dashboard Widget ---
  final double currentTemp;
  final int weatherCode;
  final double humidity;
  final double windSpeed;
  final int precipitationProbability;
  final List<HourlyForecast> hourlyForecast;

  // --- NEU: Astronomie-Basisdaten ---
  final DateTime sunrise;
  final DateTime sunset;

  ApollonLayeredWeatherResult({
    required this.isDay,
    required this.celestialProgress,
    required this.moonPhaseAsset,
    required this.showStars,
    required this.cloudCount,
    this.cloudAssetPath,
    this.weatherLayerAsset,
    required this.currentTemp,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationProbability,
    required this.hourlyForecast,
    required this.sunrise,
    required this.sunset,
  });

  /// Berechnet die Position basierend auf dem aktuellen Fortschritt (0.0 bis 1.0)
  ApollonCelestialPosition getPosition(
    double displayWidth,
    double displayHeight, {
    double? customProgress,
  }) {
    final progress = customProgress ?? celestialProgress;

    // Mittelpunkt der Ellipse (y etwas höher, damit sie über den Header geht)
    final double cx = displayWidth / 2;
    final double cy = displayHeight / 2; // 60px nach oben verschoben

    // Radien für die elliptische Bahn
    final double rx = (displayWidth / 2) - (displayWidth*.1);
    final double ry = (displayHeight / 2) - (displayHeight*.1); // Mehr vertikaler Spielraum

    // Theta von 0 bis PI für einen Halbkreis/Halbellipse
    final double theta = pi * progress;

    // x = cx - rx * cos(theta) -> startet links (0.0) und endet rechts (1.0)
    // y = cy - ry * sin(theta) -> startet auf Horizont, steigt auf Peak, endet auf Horizont
    return ApollonCelestialPosition(
      cx - (rx * cos(theta)),
      cy - (ry * sin(theta)),
    );
  }

  /// Berechnet den aktuellen Fortschritt (0.0 bis 1.0) für Sonne/Mond dynamisch
  double calculateCurrentProgress(DateTime now) {
    if (now.isAfter(sunrise) && now.isBefore(sunset)) {
      // TAG: Fortschritt von Sunrise bis Sunset
      final total = sunset.difference(sunrise).inSeconds;
      final passed = now.difference(sunrise).inSeconds;
      return (passed / total).clamp(0.0, 1.0);
    } else {
      // NACHT: Fortschritt von Sunset bis Sunrise (nächster Tag)
      DateTime start = sunset;
      DateTime end = sunrise;

      if (now.isAfter(sunset)) {
        end = sunrise.add(const Duration(days: 1));
      } else {
        start = sunset.subtract(const Duration(days: 1));
      }

      final total = end.difference(start).inSeconds;
      final passed = now.difference(start).inSeconds;
      return (passed / total).clamp(0.0, 1.0);
    }
  }
}
