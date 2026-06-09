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
  State<ApollonFlyingCloudsLayer> createState() => _ApollonFlyingCloudsLayerState();
}

class _ApollonFlyingCloudsLayerState extends State<ApollonFlyingCloudsLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_CloudData> _clouds = [];
  final Random _rnd = Random();

  // Wir speichern den exakten Startzeitpunkt der Animation
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Der Controller muss nicht mehr 60 Sekunden laufen. Er dient nur noch als
    // Frame-Trigger für den AnimatedBuilder. Eine Sekunde reicht völlig.
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

    // Wolken-Eigenschaften generieren
    for (int i = 0; i < widget.cloudCount; i++) {
      _clouds.add(_CloudData(
        topOffset: _rnd.nextDouble() * 80,
        scale: 0.6 + (_rnd.nextDouble() * 0.6),
        speedMultiplier: 0.7 + _rnd.nextDouble(),
        startProgress: _rnd.nextDouble(),
      ));
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
        // Echte vergangene Zeit in Sekunden seit dem Start berechnen
        final double elapsedSeconds = DateTime.now().difference(_startTime).inMilliseconds / 1000.0;

        return Stack(
          children: _clouds.map((cloud) {
            final screenWidth = MediaQuery.of(context).size.width;
            final cloudWidth = 150.0 * cloud.scale;

            // Basis-Dauer: Eine Wolke (Multiplier 1.0) braucht 60 Sekunden für einen Durchlauf.
            // Durch die echte Zeit (% 1.0) gibt es nie wieder einen harten Reset!
            double progressDelta = (elapsedSeconds / 60.0) * cloud.speedMultiplier;
            double currentProgress = (cloud.startProgress + progressDelta) % 1.0;

            double xPos = screenWidth - (currentProgress * (screenWidth + cloudWidth));

            return Positioned(
              top: cloud.topOffset,
              left: xPos,
              child: SizedBox(
                width: cloudWidth,
                child: Lottie.asset(widget.cloudAssetPath),
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

  _CloudData({
    required this.topOffset,
    required this.scale,
    required this.speedMultiplier,
    required this.startProgress,
  });
}