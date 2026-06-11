import 'dart:async';
import 'package:flutter/material.dart';

import '../models/weather/apollon_layered_weather_result.dart';
import '../services/apollon_weather_service.dart';

class ApollonWeatherProvider extends ChangeNotifier {
  final ApollonWeatherService _weatherService = ApollonWeatherService();

  ApollonLayeredWeatherResult? _weatherData;
  bool _isLoading = true;
  Timer? _timer;

  // Getter für die UI
  ApollonLayeredWeatherResult? get weatherData => _weatherData;
  bool get isLoading => _isLoading;

  ApollonWeatherProvider() {
    // 1. Beim Start der App direkt die Daten holen
    loadWeather();

    // 2. Einen Timer setzen, der alle 30 Minuten neue Daten zieht.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      loadWeather();
    });
  }

  Future<void> loadWeather() async {
    final newData = await _weatherService.fetchCurrentWeather();
    _weatherData = newData;
    _isLoading = false;
    // Sagt der Flutter-Engine: "Zeichne alle Widgets neu, die hierauf lauschen!"
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Wichtig, um Memory Leaks zu vermeiden
    super.dispose();
  }
}
