import 'package:flutter/material.dart';

import '../../util/custom_box_shadow.dart';

class DashboardWidgetContainer extends StatefulWidget {
  final Widget child;

  const DashboardWidgetContainer({super.key, required this.child});

  @override
  State<DashboardWidgetContainer> createState() =>
      _DashboardWidgetContainerState(child: child);
}

class _DashboardWidgetContainerState extends State<DashboardWidgetContainer> {
  final Widget child;

  _DashboardWidgetContainerState({required this.child});

  @override
  Widget build(BuildContext context) {
    var colors = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primary.withAlpha(35),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: colors.tertiary.withAlpha(80), width: 4),
        boxShadow: <BoxShadow>[
          CustomBoxShadow(color: colors.tertiary.withAlpha(150)),
        ],
      ),
      child: child,
    );
  }
}
