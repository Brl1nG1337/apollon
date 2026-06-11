import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_expansion_provider.dart';

class DashboardWidgetContainer extends StatefulWidget {
  final Widget child;
  final Widget? detailChild;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const DashboardWidgetContainer({
    super.key,
    required this.child,
    this.detailChild,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });

  @override
  State<DashboardWidgetContainer> createState() => _DashboardWidgetContainerState();
}

class _DashboardWidgetContainerState extends State<DashboardWidgetContainer> {
  final GlobalKey _key = GlobalKey();

  void _triggerExpansion() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // Berechnung der relativen Position innerhalb des ApollonPageContainers
      final offset = renderBox.localToGlobal(Offset.zero, ancestor: Navigator.of(context).context.findRenderObject());
      final rect = offset & renderBox.size;

      context.read<DashboardExpansionProvider>().expand(
        child: widget.child,
        detailChild: widget.detailChild ?? _buildDefaultDetail(),
        rect: rect,
        padding: widget.padding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wenn dieses Widget gerade expandiert ist, lassen wir einen Platzhalter im Layout
    return Consumer<DashboardExpansionProvider>(
      builder: (context, expansionProv, child) {
        final bool isSelfActive = expansionProv.activeWidget == widget.child;

        return Opacity(
          opacity: isSelfActive ? 0 : 1,
          child: GestureDetector(
            onTap: _triggerExpansion,
            child: Container(
              key: _key,
              child: _buildGlassContainer(
                borderRadius: BorderRadius.circular(28),
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassContainer({
    required BorderRadius borderRadius,
    required EdgeInsets padding,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.white.withValues(alpha: 0.18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDefaultDetail() {
    return const Center(
      child: Text(
        'Detail Ansicht',
        style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
      ),
    );
  }
}
