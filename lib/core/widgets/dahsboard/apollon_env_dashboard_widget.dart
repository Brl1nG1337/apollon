import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_widget_container.dart';

class ApollonEnvDashboardWidget extends StatelessWidget {
  const ApollonEnvDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardWidgetContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kinderzimmer / Growzelt',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Stats (Temp & Humidity)
          Row(
            children: [
              Expanded(child: _buildMainStat('24.6°', 'Temperatur')),
              const SizedBox(width: 8),
              Expanded(child: _buildMainStat('55%', 'Luftfeuchtigkeit')),
            ],
          ),
          const SizedBox(height: 16),

          // Fan Controls (Zuluft / Abluft)
          Row(
            children: [
              Expanded(
                child: _buildFanControl('Zuluft', 'Ein', 0.6, Colors.lightGreenAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFanControl('Abluft', 'Ein', 0.4, Colors.lightGreenAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Footer Stats (VPD & Soll Temp)
          Row(
            children: [
              Expanded(
                child: _buildFooterStat(Icons.eco_outlined, 'VPD', '1.2 kPa', Colors.lightGreenAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFooterStat(Icons.thermostat_rounded, 'Soll', '24.0°', Colors.white.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFanControl(String label, String status, double progress, Color progressColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.air_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            status,
            style: GoogleFonts.plusJakartaSans(
              color: progressColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          'Stufe 2',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterStat(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    color: valueColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
