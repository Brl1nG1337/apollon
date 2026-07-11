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
            // ─── LINKE SPALTE: Aktuelle Bedingungen ───────────────────────
            Expanded(
              flex: 5,
              child: _LeftColumn(data: data),
            ),

            const SizedBox(width: 20),
            Container(width: 1, color: Colors.white24),
            const SizedBox(width: 20),

            // ─── RECHTE SPALTE: Stündliche + Tages-Prognose ───────────────
            Expanded(
              flex: 7,
              child: _RightColumn(data: data),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LINKE SPALTE
// ─────────────────────────────────────────────────────────────────────────────
class _LeftColumn extends StatelessWidget {
  final ApollonLayeredWeatherResult data;
  const _LeftColumn({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Großes Wetter-Icon + Temperatur
        _buildHeroSection(),
        const Spacer(),
        // Metrics-Grid
        _buildMetricsGrid(),
        const Spacer(),
        // Sonnenzeiten
        _buildSunriseSunset(),
      ],
    );
  }

  Widget _buildHeroSection() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Lottie.asset(
              _getWmoLottie(data.weatherCode, data.isDay),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.currentTemp.round()}',
                    style: GoogleFonts.audiowide(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      shadows: _shadow,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '°C',
                      style: GoogleFonts.audiowide(
                        color: Colors.white60,
                        fontSize: 22,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  shadows: _shadow,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.orange, size: 14),
                  Text(
                    ' Gefühlt ${data.apparentTemp.round()}°C',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.water_drop_outlined,
                iconColor: Colors.lightBlueAccent,
                label: 'Luftfeuchte',
                value: '${data.humidity.round()}%',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.umbrella_rounded,
                iconColor: Colors.indigoAccent,
                label: 'Regenrisiko',
                value: '${data.precipitationProbability}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.air_rounded,
                iconColor: Colors.tealAccent,
                label: 'Wind',
                value: '${data.windSpeed.round()} km/h',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.arrow_upward_rounded,
                iconColor: Colors.orangeAccent,
                label: 'Max / Min',
                value: '${data.dailyMax.round()}° / ${data.dailyMin.round()}°',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSunriseSunset() {
    final fmt = DateFormat('HH:mm');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SunTime(
              icon: Icons.wb_twilight_rounded,
              iconColor: Colors.orangeAccent,
              label: 'Sonnenaufgang',
              time: fmt.format(data.sunrise),
            ),
            const SizedBox(width: 16),
            Container(width: 1, height: 42, color: Colors.white24),
            const SizedBox(width: 16),
            _SunTime(
              icon: Icons.nights_stay_rounded,
              iconColor: Colors.deepPurpleAccent,
              label: 'Sonnenuntergang',
              time: fmt.format(data.sunset),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECHTE SPALTE
// ─────────────────────────────────────────────────────────────────────────────
class _RightColumn extends StatelessWidget {
  final ApollonLayeredWeatherResult data;
  const _RightColumn({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'STÜNDLICHE PROGNOSE', icon: Icons.schedule_rounded),
        const SizedBox(height: 8),
        _buildHourlyForecast(),
        const Spacer(),
        _SectionLabel(label: 'MEHRTÄGIGE PROGNOSE', icon: Icons.calendar_month_rounded),
        const SizedBox(height: 8),
        _buildDailyForecast(),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    final hourly = data.hourlyForecast.take(8).toList();
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final h = hourly[index];
          final isNow = index == 0;
          return _HourlyItem(forecast: h, isNow: isNow, isDay: data.isDay);
        },
      ),
    );
  }

  Widget _buildDailyForecast() {
    final daily = data.dailyForecast.skip(1).take(4).toList();
    final allMin = daily.map((d) => d.minTemp).reduce((a, b) => a < b ? a : b);
    final allMax = daily.map((d) => d.maxTemp).reduce((a, b) => a > b ? a : b);

    return Column(
      children: daily.asMap().entries.map((entry) {
        final index = entry.key;
        final d = entry.value;
        final isLast = index == daily.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: _shadow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _SunTime extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String time;

  const _SunTime({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              time,
              style: GoogleFonts.audiowide(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
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
        Icon(icon, color: const Color(0xFFFFB000), size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.audiowide(
            color: const Color(0xFFFFB000),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _HourlyItem extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isNow;
  final bool isDay;

  const _HourlyItem({
    required this.forecast,
    required this.isNow,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        isNow ? 'Jetzt' : DateFormat('HH:mm').format(forecast.time);

    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isNow
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNow ? Colors.white38 : Colors.white12,
          width: isNow ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            timeLabel,
            style: GoogleFonts.plusJakartaSans(
              color: isNow ? const Color(0xFFFFB000) : Colors.white60,
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: Lottie.asset(
              _getWmoLottie(forecast.weatherCode, isDay),
              fit: BoxFit.contain,
            ),
          ),
          Text(
            '${forecast.temperature.round()}°',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              shadows: _shadow,
            ),
          ),
        ],
      ),
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
    final dayName =
        DateFormat('EEE', 'de_DE').format(forecast.date).toUpperCase();
    final range = rangeMax - rangeMin;
    final barStart =
        range == 0 ? 0.0 : (forecast.minTemp - rangeMin) / range;
    final barWidth =
        range == 0 ? 1.0 : (forecast.maxTemp - forecast.minTemp) / range;

    return Row(
      children: [
        // Tag-Name
        SizedBox(
          width: 38,
          child: Text(
            dayName,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Wetter-Icon
        SizedBox(
          width: 28,
          height: 28,
          child: Lottie.asset(
            _getWmoLottie(forecast.weatherCode, true),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        // Min-Temp
        SizedBox(
          width: 34,
          child: Text(
            '${forecast.minTemp.round()}°',
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.lightBlueAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Temperatur-Balken
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * barStart,
                    width: constraints.maxWidth * barWidth.clamp(0.05, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.lightBlueAccent, Colors.orangeAccent],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        // Max-Temp
        SizedBox(
          width: 34,
          child: Text(
            '${forecast.maxTemp.round()}°',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.orangeAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

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
