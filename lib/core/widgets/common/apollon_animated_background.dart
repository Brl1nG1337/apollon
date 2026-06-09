import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../providers/apollon_weather_provider.dart';
import 'apollon_flying_clouds_layer.dart';

class ApollonAnimatedBackground extends StatefulWidget {
  const ApollonAnimatedBackground({super.key});

  @override
  State<ApollonAnimatedBackground> createState() => _ApollonAnimatedBackgroundState();
}

class _ApollonAnimatedBackgroundState extends State<ApollonAnimatedBackground> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApollonWeatherProvider>(
      builder: (context, weatherProv, child) {
        // Falls die API beim allerersten Start noch lädt
        if (weatherProv.isLoading || weatherProv.weatherData == null) {
          return Container(
            color: const Color(0xFF0B1026),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final weatherData = weatherProv.weatherData!;
        final screenWidth = MediaQuery.of(context).size.width;

        // Der Horizont liegt im unteren Bereich des 5-Zoll Displays
        final horizonHeight = MediaQuery.of(context).size.height * 0.8;
        final celestialPos = weatherData.getPosition(screenWidth, horizonHeight);

        return Stack(
          children: [
            // ==========================================
            // EBENE 0: AnimatedContainer mit LinearGradient
            // ==========================================
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: weatherData.isDay
                      ? [Colors.lightBlue.shade300, Colors.lightBlue.shade100]
                      : [const Color(0xFF0B1026), const Color(0xFF1B2755)],
                ),
              ),
            ),

            // ==========================================
            // EBENE 1: Sonne oder SVG-Mond
            // ==========================================
            Positioned(
              left: celestialPos.left,
              top: celestialPos.top,
              child: weatherData.isDay
                  ? Lottie.asset('lottie/animated-background/sun.json', width: 90, height: 90)
              // Hier wird jetzt das SVG gerendert!
                  : SvgPicture.asset(weatherData.moonPhaseAsset, width: 90, height: 90),
            ),

            // ==========================================
            // EBENE 2a: Die dynamischen Wolken (Fliegen umher)
            // ==========================================
            if (weatherData.cloudAssetPath != null)
              ApollonFlyingCloudsLayer(
                cloudCount: weatherData.cloudCount,
                cloudAssetPath: weatherData.cloudAssetPath!,
              ),

            // ==========================================
            // EBENE 2b: Regen / Schnee / Gewitter (Vollbild-Overlays)
            // ==========================================
            if (weatherData.weatherLayerAsset != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.8,
                  child: Lottie.asset(
                    weatherData.weatherLayerAsset!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}