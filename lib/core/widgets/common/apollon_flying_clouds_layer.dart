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

  @override
  void initState() {
    super.initState();
    // Ein Durchlauf dauert 60 Sekunden, läuft danach endlos weiter
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

    // Wolken-Eigenschaften generieren (Höhe, Größe, Geschwindigkeit)
    for (int i = 0; i < widget.cloudCount; i++) {
      _clouds.add(_CloudData(
        topOffset: _rnd.nextDouble() * 150, // Wolken bleiben in den oberen 150 Pixeln
        scale: 0.6 + (_rnd.nextDouble() * 0.6), // Größe zwischen 60% und 120%
        speedMultiplier: 0.5 + _rnd.nextDouble(), // Unterschiedliche Geschwindigkeiten
        startProgress: _rnd.nextDouble(), // Verteilt sie anfangs über den ganzen Bildschirm
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
        return Stack(
          children: _clouds.map((cloud) {
            final screenWidth = MediaQuery.of(context).size.width;
            final cloudWidth = 200.0 * cloud.scale;

            // Berechnet die aktuelle X-Position (fliegt von rechts nach links)
            double currentProgress = (cloud.startProgress + (_controller.value * cloud.speedMultiplier)) % 1.0;
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