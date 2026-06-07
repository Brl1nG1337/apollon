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

class _DashboardWeatherTimeWidgetState extends State<DashboardWeatherTimeWidget> {
  late DateTime _currentTime;
  Timer? _clockTimer;
  Timer? _weatherTimer;

  final WeatherService _weatherService = WeatherService();
  String _currentLottieAsset = 'assets/lottie/cloudy day.json';

  // Wir halten die formatierte Zeit direkt als State-Variable
  String _formattedTimeStr = "00:00";

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _formattedTimeStr = _formatTime(_currentTime);

    // Uhrzeit-Update (Sekündlich)
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
          // Hier erzwingen wir die direkte Zuweisung im State-Wechsel
          _formattedTimeStr = _formatTime(_currentTime);
        });
      }
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
      print("=== APOLLON DEBUG: Geladenes Lottie-Asset ist: $_currentLottieAsset ===");
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

  String _getGreeting() {
    final hour = _currentTime.hour;
    if (hour >= 5 && hour < 12) {
      return "Guten Morgen, Basti!";
    } else if (hour >= 12 && hour < 18) {
      return "Guten Tag, Basti!";
    } else if (hour >= 18 && hour < 23) {
      return "Guten Abend, Basti!";
    } else {
      return "Hallo, Basti!";
    }
  }

  String _formatDate(DateTime time) {
    const weekdays = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"];
    const months = ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"];

    return "${weekdays[time.weekday - 1]}, ${time.day}. ${months[time.month - 1]} ${time.year}";
  }

  @override
  Widget build(BuildContext context) {
    return DashboardWidgetContainer(
      child: Stack(
        children: [
          // Wetter-Animation unten rechts
          Align(
            alignment: Alignment.bottomRight,
            child: Lottie.asset(
              _currentLottieAsset,
              key: ValueKey(_currentLottieAsset),
              height: 150,
              repeat: true,
              animate: true,
            ),
          ),

          // Große Uhrzeit unten links
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              _formattedTimeStr, // Nutzt jetzt den reinen, reaktiven String
              key: ValueKey(_formattedTimeStr), // Zwingt Flutter zum Neu-Rendern des Text-Knotens bei jeder Änderung
              style: GoogleFonts.audiowide(fontSize: 88, letterSpacing: -5),
            ),
          ),

          // Begrüßung und Datum oben links
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  key: ValueKey(_currentTime.hour), // Verhindert unnötige Repaints der Begrüßung, außer die Stunde ändert sich
                  style: GoogleFonts.audiowide(
                      fontSize: 24,
                      letterSpacing: -1,
                      color: Theme.of(context).colorScheme.primary.withAlpha(220)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_currentTime),
                  style: GoogleFonts.audiowide(fontSize: 32, letterSpacing: -2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}