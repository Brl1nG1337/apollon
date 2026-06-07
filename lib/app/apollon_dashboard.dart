import 'package:apollon/core/widgets/dahsboard/dashboard_public_transport_widget.dart';
import 'package:flutter/material.dart';
import '../core/widgets/dahsboard/dashboard_weather_time_widget.dart';

class ApollonDashboard extends StatefulWidget {
  const ApollonDashboard({super.key});

  @override
  State<ApollonDashboard> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<ApollonDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: 800,
        height: 480,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 7,
                  child: Row(
                    children: [
                      const Expanded(flex: 8, child: DashboardWeatherTimeWidget()),
                      const Expanded(flex: 4, child: Placeholder()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      // Zug nach Bielefeld (Großes Feld, flex: 6)
                      const Expanded(
                        flex: 6,
                        child: DashboardPublicTransportWidget(
                          fromId: "8000149", // Hamm Hbf
                          toId: "8000036",   // Bielefeld Hbf
                          title: "DB Bielefeld",
                        ),
                      ),
                      // Bus nach Pelkum (Kompakteres Feld, flex: 3)
                      const Expanded(
                        flex: 3,
                        child: DashboardPublicTransportWidget(
                          fromId: "8000149", // Hamm Hbf
                          toId: "363539",    // Hamm Pelkum Wiescherhövener Markt
                          title: "Bus Pelkum",
                        ),
                      ),
                      const Expanded(flex: 3, child: Placeholder()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}