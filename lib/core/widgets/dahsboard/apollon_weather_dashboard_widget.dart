import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../models/weather/apollon_layered_weather_result.dart';
import '../../providers/apollon_weather_provider.dart';
import 'dashboard_widget_container.dart';

class ApollonWeatherDashboardWidget extends StatelessWidget {
  const ApollonWeatherDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApollonWeatherProvider>(
      builder: (context, weatherProv, child) {
        if (weatherProv.isLoading || weatherProv.weatherData == null) {
          return const DashboardWidgetContainer(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final data = weatherProv.weatherData!;

        return DashboardWidgetContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Lottie.asset(
                      _getWmoLottie(data.weatherCode, data.isDay),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Außenklima',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Aktuelle Temperatur Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${data.currentTemp.round()}°',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getWmoDescription(data.weatherCode),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Regen: ${data.precipitationProbability}%',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),
              Divider(color: Colors.white.withOpacity(0.1), thickness: 1, height: 1),
              const SizedBox(height: 8),

              // Forecast Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data.hourlyForecast
                    .map((item) => _buildForecastItem(item))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForecastItem(HourlyForecast item) {
    final hour = item.time.hour.toString().padLeft(2, '0');
    final isDay = item.time.hour >= 6 && item.time.hour < 21;

    return Column(
      children: [
        Text(
          '$hour:00',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 24,
          height: 24,
          child: Lottie.asset(
            _getWmoLottie(item.weatherCode, isDay),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.temperature.round()}°',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getWmoDescription(int code) {
    if (code == 0) return "Sonnig";
    if (code <= 3) return "Bewölkt";
    if (code <= 48) return "Neblig";
    if (code <= 55) return "Niesel";
    if (code <= 65) return "Regen";
    if (code <= 75) return "Schnee";
    if (code <= 82) return "Schauer";
    return "Gewitter";
  }

  String _getWmoLottie(int code, bool isDay) {
    const base = 'lottie/';
    if (code == 0) {
      return isDay ? '${base}clear-day.json' : '${base}clear-night.json';
    }
    if (code <= 3) {
      return isDay ? '${base}cloudy-day.json' : '${base}cloudy-night.json';
    }
    if (code <= 65) {
      return isDay ? '${base}rainy-day.json' : '${base}rainy-night.json';
    }
    if (code <= 75) {
      return isDay ? '${base}snow-day.json' : '${base}snow-night.json';
    }
    return isDay ? '${base}stormy-day.json' : '${base}stormy-night.json';
  }
}
