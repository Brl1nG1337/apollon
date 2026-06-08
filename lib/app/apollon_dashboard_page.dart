import 'package:apollon/core/widgets/common/apollon_page_container.dart';
import 'package:flutter/material.dart';
import '../core/widgets/dahsboard/dashboard_settings_widget.dart';
import '../core/widgets/dahsboard/dashboard_weather_time_widget.dart';

class ApollonDashboardPage extends StatefulWidget {
  const ApollonDashboardPage({super.key});

  @override
  State<ApollonDashboardPage> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<ApollonDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return ApollonPageContainer(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 8,
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 8, child: DashboardWeatherTimeWidget()),
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
                      const Expanded(flex: 3, child: DashboardSettingsWidget()),
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