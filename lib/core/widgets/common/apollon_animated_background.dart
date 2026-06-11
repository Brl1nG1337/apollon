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
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
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
            // 1. Der atmosphärische Himmel mit Morgen- & Abendrot
            _AtmosphericSky(
              progress: progress,
              isDay: data.isDay,
              celestialPos: celestialPos,
              isRainy: isRainy,
            ),

            // 2. Himmelskörper
            Positioned(
              left: celestialPos.dx - 60,
              top: celestialPos.dy - 60,
              child: _CelestialBody(
                isDay: data.isDay,
                moonAsset: data.moonPhaseAsset,
                progress: progress,
              ),
            ),

            // 3. Wolken
            if (data.cloudAssetPath != null)
              Opacity(
                opacity: 0.6,
                child: RepaintBoundary(
                  child: ApollonFlyingCloudsLayer(
                    cloudCount: data.cloudCount,
                    cloudAssetPath: data.cloudAssetPath!,
                  ),
                ),
              ),

            // 4. Wetter-Effekte
            if (data.weatherLayerAsset != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: Lottie.asset(data.weatherLayerAsset!, fit: BoxFit.cover),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AtmosphericSky extends StatelessWidget {
  final double progress;
  final bool isDay;
  final Offset celestialPos;
  final bool isRainy;

  const _AtmosphericSky({
    required this.progress,
    required this.isDay,
    required this.celestialPos,
    required this.isRainy,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = _getSkyBaseColors();
    final glowColor = _getGlowColor();
    final horizonColor = _getHorizonColor();

    return Stack(
      children: [
        // Ebene 1: Basis-Hintergrund
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                baseColors[0],
                baseColors[1],
                baseColors[2],
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Ebene 2: Morgenrot / Abendrot Horizon Layer
        if (isDay && (progress < 0.25 || progress > 0.75))
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    glowColor.withOpacity(0.0),
                    glowColor.withOpacity(0.4),
                    glowColor.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

        // Ebene 3: Ambient Light Diffuser (rund um den Himmelskörper)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment((celestialPos.dx / 400) - 1.0, (celestialPos.dy / 240) - 1.0),
                radius: 1.2,
                colors: [
                  horizonColor.withOpacity(isDay ? 0.2 : 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        if (isRainy)
          Positioned.fill(
            child: Container(color: Colors.blueGrey.withValues(alpha: 0.3)),
          ),
      ],
    );
  }

  List<Color> _getSkyBaseColors() {
    if (!isDay) {
      return [const Color(0xFF010409), const Color(0xFF080E1C), const Color(0xFF0B1026)];
    }
    
    // Tag: Übergang von dunkleren zu helleren Blautönen
    if (progress < 0.2) {
      final t = progress / 0.2;
      return [
        Color.lerp(const Color(0xFF020510), const Color(0xFF0D1B3E), t)!,
        Color.lerp(const Color(0xFF1E3C72), const Color(0xFF2A5298), t)!,
        Color.lerp(const Color(0xFF2A5298), const Color(0xFF4A90E2), t)!,
      ];
    } else if (progress > 0.8) {
      final t = (progress - 0.8) / 0.2;
      return [
        Color.lerp(const Color(0xFF0D1B3E), const Color(0xFF020510), t)!,
        Color.lerp(const Color(0xFF2A5298), const Color(0xFF1E3C72), t)!,
        Color.lerp(const Color(0xFF4A90E2), const Color(0xFF2A5298), t)!,
      ];
    } else {
      return [const Color(0xFF0D1B3E), const Color(0xFF1E3C72), const Color(0xFF4A90E2)];
    }
  }

  Color _getHorizonColor() {
    if (!isDay) return const Color(0xFF1B2755);
    if (progress < 0.15) return const Color(0xFFFF8C00); // Goldener Aufgang
    if (progress > 0.85) return const Color(0xFFFF4500); // Roter Untergang
    return Colors.lightBlue.shade100;
  }

  Color _getGlowColor() {
    if (!isDay) return const Color(0xFF1B2755);
    
    // Sonnenaufgang (0.0 - 0.2)
    if (progress < 0.2) {
      final t = progress / 0.2;
      // Übergang von Tiefrot/Magenta zu Gold
      return Color.lerp(const Color(0xFFFF2D00), const Color(0xFFFFB300), t)!;
    }
    // Sonnenuntergang (0.8 - 1.0)
    if (progress > 0.8) {
      final t = (progress - 0.8) / 0.2;
      // Übergang von Orange zu Tiefrot/Violett
      return Color.lerp(const Color(0xFFFF8000), const Color(0xFF8E24AA), t)!;
    }
    
    return Colors.lightBlue.shade100.withValues(alpha: 0.5);
  }
}

class _CelestialBody extends StatelessWidget {
  final bool isDay;
  final String moonAsset;
  final double progress;

  const _CelestialBody({
    required this.isDay,
    required this.moonAsset,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    Color glowColor = isDay ? Colors.orange : Colors.blue;
    
    if (isDay) {
      if (progress < 0.2) {
        glowColor = Color.lerp(Colors.redAccent, Colors.orangeAccent, progress / 0.2)!;
      } else if (progress > 0.8) {
        glowColor = Color.lerp(Colors.orangeAccent, Colors.deepOrange, (progress - 0.8) / 0.2)!;
      }
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: 70,
            spreadRadius: 30,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 120,
            spreadRadius: 50,
          ),
        ],
      ),
      child: Center(
        child: isDay
            ? Lottie.asset('assets/lottie/sun.json', width: 90, height: 90)
            : SvgPicture.asset(moonAsset, width: 80, height: 80),
      ),
    );
  }
}
