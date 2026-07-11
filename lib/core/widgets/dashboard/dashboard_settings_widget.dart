import 'package:apollon/core/widgets/dashboard/dashboard_widget_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/apollon_settings_page.dart';

class DashboardSettingsWidget extends StatelessWidget {
  const DashboardSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardWidgetContainer(
      child: IconButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ApollonSettingsPage();
        },));
      }, icon: Icon(Icons.settings_rounded, size: 96,)),
    );
  }
}
