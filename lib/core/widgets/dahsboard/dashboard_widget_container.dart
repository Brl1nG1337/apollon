import 'package:flutter/material.dart';
import '../../util/custom_box_shadow.dart';

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withAlpha(35),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.tertiary.withAlpha(80), width: 4),
        // boxShadow: <BoxShadow>[
        //   CustomBoxShadow(color: colors.tertiary.withAlpha(150)),
        // ],
      ),
      // Wenn isLoading true ist, zentrieren wir den Ladekreis. Ansonsten zeigen wir das Widget.
      child: widget.isLoading
          ? Center(
        child: CircularProgressIndicator(
          // Verwendet die Primärfarbe deines Apollon-Themes für den Spinner
          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          strokeWidth: 4,
        ),
      )
          : widget.child,
    );
  }
}