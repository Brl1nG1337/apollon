import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ApollonFlyingCloudsLayer extends StatefulWidget {
  final int cloudCount;
  final String cloudAssetPath;

  const ApollonFlyingCloudsLayer({
    super.key,
    required this.cloudCount,
    required this.cloudAssetPath,
  });

  @override
  State<ApollonFlyingCloudsLayer> createState() =>
      _ApollonFlyingCloudsLayerState();
}

class _ApollonFlyingCloudsLayerState extends State<ApollonFlyingCloudsLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_CloudData> _clouds = [];
  final Random _rnd = Random();
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _generateClouds();
  }

  @override
  void didUpdateWidget(ApollonFlyingCloudsLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Falls sich die Anzahl der Wolken massiv ändert (z.B. Wetterumschwung), 
    // generieren wir sie neu, aber behalten den Startzeitpunkt bei.
    if (oldWidget.cloudCount != widget.cloudCount) {
      _generateClouds();
    }
  }

  void _generateClouds() {
    _clouds.clear();
    for (int i = 0; i < widget.cloudCount; i++) {
      final double scale = 0.3 + (_rnd.nextDouble() * 0.5); // Deutlich kleinere Skalierung
      _clouds.add(
        _CloudData(
          topOffset: _rnd.nextDouble() * 100, // Etwas kompakterer Bereich
          scale: scale,
          // Parallax-Effekt: Große Wolken (vorne) bewegen sich schneller
          speedMultiplier: (0.7 + _rnd.nextDouble() * 0.5) * (scale + 0.5),
          startProgress: _rnd.nextDouble(),
          driftPhase: _rnd.nextDouble() * pi * 2,
          driftIntensity: 3.0 + (_rnd.nextDouble() * 10.0), // Weniger vertikaler Drift
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cloudCount == 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double elapsedSeconds =
            DateTime.now().difference(_startTime).inMilliseconds / 1000.0;

        return Stack(
          children: _clouds.map((cloud) {
            final screenWidth = 800.0; // Feste Referenzbreite
            final cloudWidth = 140.0 * cloud.scale; // Reduzierte Basisbreite
            
            // Horizontale Position mit Zeit-Fortschritt (Divisor von 80 auf 50 reduziert für mehr Speed)
            double progressDelta = (elapsedSeconds / 50.0) * cloud.speedMultiplier;
            double currentProgress = (cloud.startProgress + progressDelta) % 1.0;
            double xPos = screenWidth - (currentProgress * (screenWidth + cloudWidth));

            // Vertikaler Drift (Sinus-Welle für organisches Schweben)
            double drift = sin((elapsedSeconds * 0.5) + cloud.driftPhase) * cloud.driftIntensity;

            return Positioned(
              top: cloud.topOffset + drift,
              left: xPos,
              child: Transform.scale(
                scale: cloud.scale,
                child: SizedBox(
                  width: 140, // Reduzierte Basisbreite
                  child: Lottie.asset(
                    widget.cloudAssetPath,
                    // Wir verlangsamen die interne Lottie-Animation leicht für mehr Ruhe
                    repeat: true,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CloudData {
  final double topOffset;
  final double scale;
  final double speedMultiplier;
  final double startProgress;
  final double driftPhase;
  final double driftIntensity;

  _CloudData({
    required this.topOffset,
    required this.scale,
    required this.speedMultiplier,
    required this.startProgress,
    required this.driftPhase,
    required this.driftIntensity,
  });
}
