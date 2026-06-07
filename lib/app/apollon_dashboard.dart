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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: Row(
                      children: [
                        const Expanded(flex: 8, child: DashboardWeatherTimeWidget()),
                        const SizedBox(width: 16),
                        const Expanded(flex: 4, child: Placeholder()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Placeholder()
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Placeholder()
                        ),
                        const SizedBox(width: 16),
                        const Expanded(flex: 3, child: Placeholder()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}