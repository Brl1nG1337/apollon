import 'dart:async';
import 'dart:ui';
import 'package:apollon/core/widgets/dahsboard/apollon_dashboard_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/common/apollon_animated_background.dart';
import '../widgets/common/apollon_page_container.dart';
import '../widgets/dahsboard/apollon_weather_dashboard_widget.dart';
import '../widgets/dahsboard/dashboard_widget_container.dart';
import '../providers/dashboard_expansion_provider.dart';

class ApollonDashboardPage extends StatefulWidget {
  const ApollonDashboardPage({super.key});

  @override
  State<ApollonDashboardPage> createState() => _ApollonDashboardPageState();
}

class _ApollonDashboardPageState extends State<ApollonDashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApollonPageContainer(
        child: Consumer<DashboardExpansionProvider>(
          builder: (context, expansionProv, child) {
            // Wenn der Provider expandiert meldet, starten wir die Animation
            if (expansionProv.isExpanded && _animationController.status == AnimationStatus.dismissed) {
              _animationController.forward();
            }

            return Stack(
              children: [
                // EBENE 0: Der dynamische Wetterhintergrund (Bleibt immer sichtbar)
                const ApollonAnimatedBackground(),

                // EBENE 1: Normaler Dashboard Content (Fadet aus wenn expandiert)
                FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_animation),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ApollonDashboardHeader(),
                        const Expanded(child: SizedBox()),
                        SizedBox(
                          height: 260,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Expanded(child: ApollonWeatherDashboardWidget()),
                              const SizedBox(width: 16),
                              Expanded(child: DashboardWidgetContainer(child: Container())),
                              const SizedBox(width: 16),
                              Expanded(child: DashboardWidgetContainer(child: Container())),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // EBENE 2: Das expandierende Widget (The "Grow" Layer)
                if (expansionProv.isExpanded)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final t = _animation.value;
                      final startRect = expansionProv.sourceRect!;
                      // Target ist der volle 800x480 Raum
                      final targetRect = const Rect.fromLTWH(0, 0, 800, 480);
                      final currentRect = Rect.lerp(startRect, targetRect, t)!;

                      // Synchronisierter Content-Fade
                      final widgetOpacity = (1 - (t * 2.5)).clamp(0.0, 1.0);
                      final detailOpacity = ((t - 0.4) * 2.5).clamp(0.0, 1.0);

                      return Stack(
                        children: [
                          Positioned.fromRect(
                            rect: currentRect,
                            child: GestureDetector(
                              onTap: () {
                                _animationController.reverse().then((_) {
                                  expansionProv.close();
                                });
                              },
                              child: _buildExpandingContainer(
                                t: t,
                                widgetOpacity: widgetOpacity,
                                detailOpacity: detailOpacity,
                                expansionProv: expansionProv,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandingContainer({
    required double t,
    required double widgetOpacity,
    required double detailOpacity,
    required DashboardExpansionProvider expansionProv,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(lerpDouble(28, 0, t)!),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.lerp(expansionProv.sourcePadding, const EdgeInsets.all(32), t),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: lerpDouble(0.18, 0.25, t)!),
            border: Border.all(
              color: Colors.white.withValues(alpha: lerpDouble(0.35, 0.1, t)!),
              width: lerpDouble(1.5, 0, t)!,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Alter Inhalt fadet aus
              if (widgetOpacity > 0)
                Opacity(
                  opacity: widgetOpacity,
                  child: expansionProv.activeWidget,
                ),
              // Neuer Inhalt (Details) fadet ein
              if (detailOpacity > 0)
                Opacity(
                  opacity: detailOpacity,
                  child: Material(
                    color: Colors.transparent,
                    child: expansionProv.activeDetail,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
