import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ];

        return DashboardWidgetContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              // --- TOP SECTION ---
              _buildTopSection(data, textShadow),
              const Spacer(),

              // --- MIDDLE SECTION ---
              _buildMiddleSection(data, textShadow),
              const Spacer(),

              // --- BOTTOM SECTION (Forecast) ---
              _buildForecastSection(data, textShadow),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSection(ApollonLayeredWeatherResult data, List<Shadow> shadow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Lottie.asset(
            _getWmoLottie(data.weatherCode, data.isDay),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${data.currentTemp.round()}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    shadows: shadow,
                  ),
                ),
                Text(
                  '°',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    shadows: shadow,
                  ),
                ),
              ],
            ),
            Text(
              _getWmoDescription(data.weatherCode),
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                shadows: shadow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiddleSection(ApollonLayeredWeatherResult data, List<Shadow> shadow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricItem(
                icon: Icons.thermostat,
                label: 'Gefühlt',
                value: '${data.apparentTemp.round()}°',
                shadow: shadow,
                iconColor: Colors.orangeAccent,
              ),
              const SizedBox(height: 4),
              _buildMetricItem(
                icon: Icons.water_drop,
                label: 'Regen',
                value: '${data.precipitationProbability}%',
                shadow: shadow,
                iconColor: Colors.lightBlueAccent,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              _buildMinMaxItem(Icons.arrow_upward, Colors.orange, data.dailyMax, shadow),
              const SizedBox(height: 2),
              Container(width: 30, height: 1, color: Colors.white24),
              const SizedBox(height: 2),
              _buildMinMaxItem(Icons.arrow_downward, Colors.lightBlue, data.dailyMin, shadow),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinMaxItem(IconData icon, Color color, double val, List<Shadow> shadow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 2),
        Text(
          '${val.round()}°',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            shadows: shadow,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required List<Shadow> shadow,
    required Color iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  shadows: shadow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  shadows: shadow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastSection(ApollonLayeredWeatherResult data, List<Shadow> shadow) {
    final forecast = data.dailyForecast.skip(1).take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < forecast.length; i++) ...[
            _buildDailyForecastItem(forecast[i], shadow),
            if (i < forecast.length - 1)
              Container(width: 1, height: 40, color: Colors.white12),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyForecastItem(DailyForecast item, List<Shadow> shadow) {
    final dayName = DateFormat('EE', 'de_DE').format(item.date).toUpperCase();

    return Expanded(
      child: Column(
        children: [
          Text(
            dayName,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              shadows: shadow,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${item.maxTemp.round()}°',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  shadows: shadow,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '${item.minTemp.round()}°',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  shadows: shadow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWmoDescription(int code) {
    if (code == 0) return "Sonnig";
    if (code <= 3) return "Leicht bewölkt";
    if (code <= 48) return "Neblig";
    if (code <= 55) return "Nieselregen";
    if (code <= 65) return "Regnerisch";
    if (code <= 75) return "Schneefall";
    if (code <= 82) return "Regenschauer";
    return "Gewitter";
  }

  String _getWmoLottie(int code, bool isDay) {
    const base = 'assets/lottie/';
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
