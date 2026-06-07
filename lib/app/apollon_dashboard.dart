import 'package:apollon/widgets/dahsboard/dashboard_weather_time_widget.dart';
import 'package:flutter/material.dart';

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
                  flex: 8,
                  child: Row(
                    children: [
                      Expanded(flex: 8, child: DashboardWeatherTimeWidget()),
                      Expanded(flex: 4, child: Placeholder()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(flex: 6, child: Placeholder()),
                      Expanded(flex: 3, child: Placeholder()),
                      Expanded(flex: 3, child: Placeholder()),
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
