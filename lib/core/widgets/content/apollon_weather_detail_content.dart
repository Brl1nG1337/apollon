import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../models/weather/apollon_layered_weather_result.dart';
import '../../providers/apollon_weather_provider.dart';

class ApollonWeatherDetailContent extends StatelessWidget {
  const ApollonWeatherDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApollonWeatherProvider>(
      builder: (context, weatherProv, _) {
        if (weatherProv.isLoading || weatherProv.weatherData == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final data = weatherProv.weatherData!;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── LINKE SPALTE: Gigantisches aktuelles Wetter ──────────────
            Expanded(
              flex: 1, // 50% der Breite
              child: _LeftColumn(data: data),
            ),

            const SizedBox(width: 24),
            Container(width: 2, color: Colors.white12), // Etwas dickerer Trenner
            const SizedBox(width: 24),

            // ─── RECHTE SPALTE: Große 3-Tages-Prognose ────────────────────
            Expanded(
              flex: 1, // 50% der Breite
              child: _RightColumn(data: data),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LINKE SPALTE: Fokus auf Lesbarkeit aus der Ferne
// ─────────────────────────────────────────────────────────────────────────────
class _LeftColumn extends StatelessWidget {
  final ApollonLayeredWeatherResult data;
  const _LeftColumn({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Dieser Spacer drückt alles nach unten, weg vom Zurück-Button
        const Spacer(),

        // 2. Das große Icon und die Temperatur
        _buildHeroSection(),

        // 3. Fester, großer Abstand zu den Metriken
        const SizedBox(height: 32),

        // 4. Luftfeuchte & Wind
        _buildEssentialMetrics(),

        // 5. Etwas Luft zum unteren Bildschirmrand
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Row(
      // WICHTIG: Richtet das Lottie-Icon und den Textblock unten bündig an einer Linie aus!
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Lottie.asset(
            _getWmoLottie(data.weatherCode, data.isDay),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.currentTemp.round()}',
                    style: GoogleFonts.audiowide(
                      color: Colors.white,
                      fontSize: 96, // Riesig
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      shadows: _shadow,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      '°C',
                      style: GoogleFonts.audiowide(
                        color: Colors.white60,
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        shadows: _shadow,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                _getWmoDescription(data.weatherCode),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  shadows: _shadow,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.orange, size: 20),
                  Text(
                    ' Gefühlt ${data.apparentTemp.round()}°C',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEssentialMetrics() {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.umbrella_rounded,
            iconColor: Colors.indigoAccent,
            label: 'Regenrisiko',
            value: '${data.precipitationProbability}%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricTile(
            icon: Icons.air_rounded,
            iconColor: Colors.tealAccent,
            label: 'Wind',
            value: '${data.windSpeed.round()} km/h',
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECHTE SPALTE: Reduziert auf 3 Tage, extrem gut ablesbar
// ─────────────────────────────────────────────────────────────────────────────
class _RightColumn extends StatelessWidget {
  final ApollonLayeredWeatherResult data;
  const _RightColumn({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _SectionLabel(label: 'NÄCHSTE TAGE', icon: Icons.calendar_month_rounded),
        const SizedBox(height: 24),
        _buildDailyForecast(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDailyForecast() {
    final daily = data.dailyForecast.skip(1).take(3).toList();
    final allMin = daily.map((d) => d.minTemp).reduce((a, b) => a < b ? a : b);
    final allMax = daily.map((d) => d.maxTemp).reduce((a, b) => a > b ? a : b);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: daily.asMap().entries.map((entry) {
        final index = entry.key;
        final d = entry.value;
        final isLast = index == daily.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
          child: _DailyForecastRow(
            forecast: d,
            rangeMin: allMin,
            rangeMax: allMax,
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: _shadow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFB000), size: 24),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.audiowide(
            color: const Color(0xFFFFB000),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _DailyForecastRow extends StatelessWidget {
  final DailyForecast forecast;
  final double rangeMin;
  final double rangeMax;

  const _DailyForecastRow({
    required this.forecast,
    required this.rangeMin,
    required this.rangeMax,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEE', 'de_DE').format(forecast.date).toUpperCase();
    final range = rangeMax - rangeMin;
    final barStart = range == 0 ? 0.0 : (forecast.minTemp - rangeMin) / range;
    final barWidth = range == 0 ? 1.0 : (forecast.maxTemp - forecast.minTemp) / range;

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            dayName,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 42,
          height: 42,
          child: Lottie.asset(
            _getWmoLottie(forecast.weatherCode, true),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 44,
          child: Text(
            '${forecast.minTemp.round()}°',
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.lightBlueAccent,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * barStart,
                    width: constraints.maxWidth * barWidth.clamp(0.05, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.lightBlueAccent, Colors.orangeAccent],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 44,
          child: Text(
            '${forecast.maxTemp.round()}°',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.orangeAccent,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

final _shadow = [
  const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
];

String _getWmoDescription(int code) {
  if (code == 0) return 'Sonnig';
  if (code <= 3) return 'Leicht bewölkt';
  if (code <= 48) return 'Neblig';
  if (code <= 55) return 'Nieselregen';
  if (code <= 65) return 'Regnerisch';
  if (code <= 75) return 'Schneefall';
  if (code <= 82) return 'Regenschauer';
  return 'Gewitter';
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