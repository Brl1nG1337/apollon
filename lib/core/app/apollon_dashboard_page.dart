import 'package:apollon/core/widgets/dashboard/apollon_dashboard_header.dart';
import 'package:flutter/material.dart';

import '../widgets/common/apollon_animated_background.dart';
import '../widgets/common/apollon_page_container.dart';
import '../widgets/dashboard/apollon_weather_dashboard_widget.dart';
import '../widgets/dashboard/dashboard_widget_container.dart';

class ApollonDashboardPage extends StatelessWidget {
  const ApollonDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ApollonPageContainer(
        child: Stack(
          children: [
            // EBENE 0: Der dynamische Wetterhintergrund
            ApollonAnimatedBackground(),

            // EBENE 1: Normaler Dashboard Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ApollonDashboardHeader(),
                  Spacer(),
                  SizedBox(
                    height: 260,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: ApollonWeatherDashboardWidget()),
                        SizedBox(width: 16),
                        Expanded(child: DashboardWidgetContainer(child: SizedBox())),
                        SizedBox(width: 16),
                        Expanded(child: DashboardWidgetContainer(child: SizedBox())),
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
