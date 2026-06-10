import 'dart:async';
import 'dart:ui';
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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh alle 1 Sekunde für flüssige Bewegungen
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApollonWeatherProvider>(
      builder: (context, weatherProv, child) {
        if (weatherProv.isLoading || weatherProv.weatherData == null) {
          return Container(color: const Color(0xFF02040F));
        }

        final data = weatherProv.weatherData!;
        final now = DateTime.now();
        final progress = data.calculateCurrentProgress(now);
        final celestialPos = data.getPosition(800, 480, customProgress: progress).toOffset();

        final bool isRainy = data.weatherCode >= 61 && data.weatherCode <= 99;
        
        return Stack(
          children: [
            // 1. Atmos-Sky
            _NaturalSky(
              progress: progress,
              isDay: data.isDay,
              celestialPos: celestialPos,
              isRainy: isRainy,
            ),

            // 2. Himmelskörper
            Positioned(
              left: celestialPos.dx - 45,
              top: celestialPos.dy - 45,
              child: data.isDay
                  ? Lottie.asset('assets/lottie/sun.json', width: 90, height: 90)
                  : SvgPicture.asset(data.moonPhaseAsset, width: 90, height: 90),
            ),

            // 3. Wolken
            if (data.cloudAssetPath != null)
              RepaintBoundary(
                child: ApollonFlyingCloudsLayer(
                  cloudCount: data.cloudCount,
                  cloudAssetPath: data.cloudAssetPath!,
                ),
              ),

            // 4. Wetter-Effekte
            if (data.weatherLayerAsset != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.4,
                  child: Lottie.asset(data.weatherLayerAsset!, fit: BoxFit.cover),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NaturalSky extends StatelessWidget {
  final double progress;
  final bool isDay;
  final Offset celestialPos;
  final bool isRainy;

  const _NaturalSky({
    required this.progress,
    required this.isDay,
    required this.celestialPos,
    required this.isRainy,
  });

  @override
  Widget build(BuildContext context) {
    final skyColors = _getSkyBaseColors();
    final horizonColor = _getHorizonColor();

    return Stack(
      children: [
        // LAYER 1: Basis-Himmel
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: skyColors,
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        ),

        // LAYER 2: Horizon-Glow
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  horizonColor.withOpacity(isDay ? 0.4 : 0.1),
                  horizonColor.withOpacity(isDay ? 0.6 : 0.2),
                ],
                stops: const [0.3, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // LAYER 3: Sun/Moon Glow
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  (celestialPos.dx / 400) - 1.0,
                  (celestialPos.dy / 240) - 1.0,
                ),
                radius: 2.0,
                colors: [
                  (isDay ? Colors.orange.shade300 : Colors.blue.shade100)
                      .withOpacity(isDay ? 0.2 : 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // LAYER 4: Regen
        if (isRainy)
          Positioned.fill(
            child: Container(
              color: Colors.indigo.withOpacity(0.3),
            ),
          ),

        // LAYER 5: Vignette
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getSkyBaseColors() {
    if (!isDay) {
      return [
        const Color(0xFF010208),
        const Color(0xFF050A1A),
        const Color(0xFF0B1026),
      ];
    }

    if (progress < 0.2) {
      final t = (progress / 0.2);
      return [
        Color.lerp(const Color(0xFF0B1026), Colors.blue.shade900, t)!,
        Color.lerp(const Color(0xFF1E3C72), Colors.lightBlue.shade700, t)!,
        Color.lerp(const Color(0xFF2A5298), Colors.lightBlue.shade400, t)!,
      ];
    } else if (progress > 0.8) {
      final t = ((progress - 0.8) / 0.2);
      return [
        Color.lerp(Colors.blue.shade900, const Color(0xFF0B1026), t)!,
        Color.lerp(Colors.lightBlue.shade700, const Color(0xFF1B2755), t)!,
        Color.lerp(Colors.lightBlue.shade400, const Color(0xFF2A5298), t)!,
      ];
    } else {
      return [
        Colors.blue.shade900,
        Colors.lightBlue.shade700,
        Colors.lightBlue.shade400,
      ];
    }
  }

  Color _getHorizonColor() {
    if (!isDay) return const Color(0xFF1B2755);

    if (progress < 0.15) {
      final t = (progress / 0.15);
      return Color.lerp(const Color(0xFFF12711), const Color(0xFFF5AF19), t)!;
    } else if (progress > 0.85) {
      final t = ((progress - 0.85) / 0.15);
      return Color.lerp(const Color(0xFFF5AF19), const Color(0xFFE44D26), t)!;
    } else {
      return Colors.lightBlue.shade200;
    }
  }
}
