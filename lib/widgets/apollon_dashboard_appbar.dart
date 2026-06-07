import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';

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

  // Start-Werte vor dem ersten API-Load
  WeatherCondition _currentWeather = WeatherCondition.cloudy;
  bool _isDayNow = true;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();

    // Uhrzeit-Timer (jede Sekunde)
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    // Wetter alle 15 Minuten abfragen (Open-Meteo erlaubt das problemlos!)
    _updateWeather();
    _weatherTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _updateWeather();
    });
  }

  void _updateWeather() async {
    final result = await _weatherService.fetchCurrentWeather();
    if (mounted) {
      setState(() {
        _currentWeather = result.condition;
        _isDayNow = result.isDay; // Hier setzen wir den echten Tag/Nacht-Status
      });
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

  // Nutzt jetzt das präzise isNight-Flag der API
  IconData _getWeatherIcon(WeatherCondition condition, bool isDay) {
    switch (condition) {
      case WeatherCondition.sunny:
        return isDay ? WeatherIcons.day_sunny : WeatherIcons.night_clear;

      case WeatherCondition.cloudy:
        return isDay ? WeatherIcons.day_cloudy : WeatherIcons.night_alt_cloudy;

      case WeatherCondition.rainy:
        // Wunderschöne Icons: Wolke mit Mond/Sonne + Regen
        return isDay ? WeatherIcons.day_rain : WeatherIcons.night_alt_rain;

      case WeatherCondition.snowy:
        return isDay ? WeatherIcons.day_snow : WeatherIcons.night_alt_snow;

      case WeatherCondition.stormy:
        return isDay
            ? WeatherIcons.day_thunderstorm
            : WeatherIcons.night_alt_thunderstorm;
    }
  }

  @override
  Widget build(BuildContext context) {
    var colors = Theme.of(context).colorScheme;

    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        color: colors.surface,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Apollon™",
                  style: GoogleFonts.audiowide(fontSize: 36),
                ),
              ),

              // Dynamisches Icon gefüttert von Open-Meteo
              Icon(
                _getWeatherIcon(_currentWeather, _isDayNow),
                size: 40,
                color: _isDayNow ? Colors.amber : Colors.lightBlueAccent,
              ),
              const SizedBox(width: 15),

              const VerticalDivider(
                color: Colors.white,
                indent: 10,
                endIndent: 10,
                width: 20,
              ),
              Text(
                _formatTime(_currentTime),
                style: GoogleFonts.audiowide(fontSize: 36),
              ),
              const VerticalDivider(
                color: Colors.white,
                indent: 10,
                endIndent: 10,
                width: 20,
              ),
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.settings, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
