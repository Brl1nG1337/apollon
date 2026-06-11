import 'dart:async';
import 'package:apollon/core/widgets/dahsboard/apollon_dashboard_header.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/common/apollon_animated_background.dart';
import '../widgets/common/apollon_page_container.dart';
import '../widgets/dahsboard/apollon_weather_dashboard_widget.dart';
import '../widgets/dahsboard/apollon_env_dashboard_widget.dart';
import '../widgets/dahsboard/apollon_devices_dashboard_widget.dart';

class ApollonDashboardPage extends StatefulWidget {
  const ApollonDashboardPage({super.key});

  @override
  State<ApollonDashboardPage> createState() => _ApollonDashboardPageState();
}

class _ApollonDashboardPageState extends State<ApollonDashboardPage> {
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApollonPageContainer(
        child: Stack(
          children: [
            // EBENE 0: Der dynamische Wetterhintergrund
            const ApollonAnimatedBackground(),

            // EBENE 1: UI Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ApollonDashboardHeader(),
                  // FLEXIBLER RAUM: Sorgt dafür, dass die Widgets genug Platz nach oben haben
                  const Expanded(child: SizedBox()),

                  // --- WIDGET ROW: Wetter, Umgebung, Geräte ---
                  SizedBox(
                    height: 260, // Erhöhte Höhe für mehr "Luft" innerhalb der Widgets
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(child: ApollonWeatherDashboardWidget()),
                        const SizedBox(width: 16),
                        Expanded(child: Container()), // ApollonEnvDashboardWidget()
                        const SizedBox(width: 16),
                        Expanded(child: Container()), // ApollonDevicesDashboardWidget()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
