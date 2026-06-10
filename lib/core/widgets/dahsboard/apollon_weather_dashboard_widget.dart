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
        final textShadow = [
          const Shadow(
            color: Colors.black,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ];

        return DashboardWidgetContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 32,
                    child: Lottie.asset(
                      _getWmoLottie(data.weatherCode, data.isDay),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Wetter',
                      style: GoogleFonts.audiowide(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        shadows: textShadow,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

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
                        fontSize: 54,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        shadows: textShadow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getWmoDescription(data.weatherCode),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            shadows: textShadow,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Regen: ${data.precipitationProbability}%',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            shadows: textShadow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8,),
              Divider(color: Colors.white.withOpacity(0.2), thickness: 1, height: 1),
              const SizedBox(height: 10),

              // Forecast Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data.hourlyForecast
                    .map((item) => _buildForecastItem(item, textShadow))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForecastItem(HourlyForecast item, List<Shadow> shadow) {
    final hour = item.time.hour.toString().padLeft(2, '0');
    final isDay = item.time.hour >= 6 && item.time.hour < 21;

    return Column(
      children: [
        Text(
          '$hour:00',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: shadow,
          ),
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: Lottie.asset(
            _getWmoLottie(item.weatherCode, isDay),
            fit: BoxFit.contain,
          ),
        ),
        Text(
          '${item.temperature.round()}°',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            shadows: shadow,
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
