import 'dart:math';

import 'package:apollon/core/models/weather/apollon_celestial_position.dart';


class ApollonLayeredWeatherResult {
  final bool isDay;
  final double celestialProgress;
  final String moonPhaseAsset;
  final bool showStars;

  // --- NEU: Wolken & Wetter ---
  final int cloudCount;           // 0 bis z.B. 6
  final String? cloudAssetPath;   // cloud.json oder dark cloud.json
  final String? weatherLayerAsset;// rain_overlay, snow_overlay, dark cloud lightning

  ApollonLayeredWeatherResult({
    required this.isDay,
    required this.celestialProgress,
    required this.moonPhaseAsset,
    required this.showStars,
    required this.cloudCount,
    this.cloudAssetPath,
    this.weatherLayerAsset,
  });

  ApollonCelestialPosition getPosition(double displayWidth, double baseHeight) {
    double radius = displayWidth / 2.2;
    double theta = pi * celestialProgress;
    return ApollonCelestialPosition(
      radius - (radius * cos(theta)),
      baseHeight - (radius * sin(theta)),
    );
  }
}