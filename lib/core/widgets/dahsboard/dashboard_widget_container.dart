import 'package:flutter/material.dart';

class DashboardWidgetContainer extends StatefulWidget {
  final Widget child;
  final bool isLoading; // NEU: Flag für den Ladestatus

  const DashboardWidgetContainer({
    super.key,
    required this.child,
    this.isLoading = false, // Standardmäßig false, damit bestehende Widgets nicht brechen
  });

  @override
  State<DashboardWidgetContainer> createState() => _DashboardWidgetContainerState();
}

class _DashboardWidgetContainerState extends State<DashboardWidgetContainer> {
  @override
  Widget build(BuildContext context) {
    var colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primary.withAlpha(35),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.tertiary.withAlpha(80), width: 4),
      ),
      child: widget.isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          strokeWidth: 4,
        ),
      )
          : widget.child,
    );
  }
}