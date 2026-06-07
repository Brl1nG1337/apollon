import 'dart:async';

import 'package:apollon/app/apollon_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../services/apollon_weather_service.dart';

class ApollonDashboardAppbar extends StatefulWidget {
  const ApollonDashboardAppbar({super.key});

  @override
  State<ApollonDashboardAppbar> createState() => _ApollonDashboardAppbarState();
}

class _ApollonDashboardAppbarState extends State<ApollonDashboardAppbar> {
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
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute
        .toString()
        .padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    var colors = Theme
        .of(context)
        .colorScheme;

    return Container(
      // Expanded flex:1 muss im übergeordneten Widget (z.B. Column) sitzen
      height: 80, // Beispielhöhe für die AppBar
      width: double.infinity,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Apollon™",
                style: GoogleFonts.audiowide(fontSize: 36),
              ),
            ),
            const VerticalDivider(
              color: Colors.white,
              indent: 20,
              endIndent: 20,
              width: 20,
            ),
            Text(
              _formatTime(_currentTime),
              style: GoogleFonts.audiowide(fontSize: 36),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: Lottie.asset(
                _currentLottieAsset,
                fit: BoxFit.fill,
                repeat: true,
                // Sorgt dafür, dass die Animation unendlich oft von vorn startet
                animate: true,
              ),
            ),
            const VerticalDivider(
              color: Colors.white,
              indent: 20,
              endIndent: 20,
              width: 20,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const ApollonSettings()));
              },
              icon: const Icon(Icons.settings, size: 36),
            ),
          ],
        ),
      ),
    );
  }
}
