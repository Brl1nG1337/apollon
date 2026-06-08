import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../services/weather_service.dart';
import 'dashboard_widget_container.dart';

class DashboardWeatherTimeWidget extends StatefulWidget {
  const DashboardWeatherTimeWidget({super.key});

  @override
  State<DashboardWeatherTimeWidget> createState() =>
      _DashboardWeatherTimeWidgetState();
}

class _DashboardWeatherTimeWidgetState extends State<DashboardWeatherTimeWidget>
    with TickerProviderStateMixin {
  late DateTime _currentTime;
  Timer? _clockTimer;
  Timer? _weatherTimer;

  final WeatherService _weatherService = WeatherService();

  String? _currentLottieAsset;
  String _formattedTimeStr = "00:00";
  bool _fontsLoaded = false;

  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _formattedTimeStr = _formatTime(_currentTime);

    _lottieController = AnimationController(vsync: this);

    _waitForFonts();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
          _formattedTimeStr = _formatTime(_currentTime);
        });
      }
    });

    _updateWeather();
    _weatherTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _updateWeather();
    });
  }

  void _waitForFonts() async {
    GoogleFonts.audiowide();
    await GoogleFonts.pendingFonts();
    if (mounted) {
      setState(() {
        _fontsLoaded = true;
      });
    }
  }

  void _updateWeather() async {
    final result = await _weatherService.fetchCurrentWeather();
    if (mounted) {
      setState(() {
        _currentLottieAsset = result.lottieAssetPath;
      });
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _weatherTimer?.cancel();
    _lottieController.dispose();
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
    const weekdays = [
      "Montag",
      "Dienstag",
      "Mittwoch",
      "Donnerstag",
      "Freitag",
      "Samstag",
      "Sonntag"
    ];
    const months = [
      "Januar",
      "Februar",
      "März",
      "April",
      "Mai",
      "Juni",
      "Juli",
      "August",
      "September",
      "Oktober",
      "November",
      "Dezember"
    ];

    return "${weekdays[time.weekday - 1]}, ${time.day}. ${months[time.month - 1]} ${time.year}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _currentLottieAsset == null || !_fontsLoaded;

    return DashboardWidgetContainer(
      isLoading: isLoading,
      child: Stack(
        children: [
          if (_currentLottieAsset != null)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Align(
                alignment: Alignment.topRight,
                child: Lottie.asset(
                  _currentLottieAsset!,
                  key: ValueKey(_currentLottieAsset),
                  height: 150,
                  repeat: true,
                  animate: true,
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController.duration = composition.duration * 3;
                    _lottieController.repeat();
                  },
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              _formattedTimeStr,
              key: ValueKey(_formattedTimeStr),
              style: GoogleFonts.audiowide(
                fontSize: 100,
                letterSpacing: -4,
                height: 1.0,
                color: Theme.of(context).colorScheme.onSurface
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  key: ValueKey(_currentTime.hour),
                  style: GoogleFonts.audiowide(
                      fontSize: 36,
                      letterSpacing: -1,
                      color:
                      Theme.of(context).colorScheme.primary.withAlpha(220)),
                ),
                Text(
                  _formatDate(_currentTime),
                  style:
                  GoogleFonts.audiowide(fontSize: 26, letterSpacing: -1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}