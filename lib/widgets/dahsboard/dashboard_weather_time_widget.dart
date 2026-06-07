import 'dart:async';

import 'package:apollon/widgets/dahsboard/dashboard_widget_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../services/apollon_weather_service.dart';

class DashboardWeatherTimeWidget extends StatefulWidget {
  const DashboardWeatherTimeWidget({super.key});

  @override
  State<DashboardWeatherTimeWidget> createState() =>
      _DashboardWeatherTimeWidgetState();
}

class _DashboardWeatherTimeWidgetState
    extends State<DashboardWeatherTimeWidget> {
  late DateTime _currentTime;
  Timer? _clockTimer;
  Timer? _weatherTimer;

  final WeatherService _weatherService = WeatherService();
  String _currentLottieAsset = 'assets/lottie/cloudy day.json';

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();

    // Uhrzeit-Update (Sekündlich)
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    // Wetter-Update (Alle 15 Min)
    _updateWeather();
    _weatherTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _updateWeather();
    });
  }

  void _updateWeather() async {
    final result = await _weatherService.fetchCurrentWeather();
    if (mounted) {
      setState(() {
        _currentLottieAsset = result.lottieAssetPath;
      });
      // HIER: Das druckt dir den geladenen Pfad direkt ins IntelliJ/VS-Code Terminal!
      print(
        "=== APOLLON DEBUG: Geladenes Lottie-Asset ist: $_currentLottieAsset ===",
      );
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return DashboardWidgetContainer(
      child: Stack(
        children: [
          Align(
            alignment: AlignmentGeometry.bottomRight,
            child: Lottie.asset(
              _currentLottieAsset,
              height: 200,
              repeat: true,
              animate: true,
            ),
          ),
          Align(
            alignment: AlignmentGeometry.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 24),
              child: Text(
                _formatTime(DateTime.now()),
                style: GoogleFonts.audiowide(fontSize: 72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
