import 'package:apollon/core/widgets/common/apollon_animated_background.dart';
import 'package:flutter/material.dart';

class ApollonDashboardPage extends StatefulWidget {
  const ApollonDashboardPage({super.key});

  @override
  State<ApollonDashboardPage> createState() => _ApollonDashboardPageState();
}

class _ApollonDashboardPageState extends State<ApollonDashboardPage> {
  // 1. Controller für die PageView hinzufügen
  final PageController _pageController = PageController();

  // 2. Zustand für den aktuellen Index speichern
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // EBENE 0-2: Autarker Wetter-Hintergrund
          // ==========================================
          const ApollonAnimatedBackground(),

          // ==========================================
          // EBENE 3: Dashboard-UI (Transparent)
          // ==========================================
          RepaintBoundary(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      // 3. Wenn gewischt wird, State aktualisieren
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        // Seite 0: Hauptübersicht
                        Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: Text("Hauptmenü", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        // Seite 1: Raumsteuerung
                        Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: Text("Räume", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        // Seite 2: Einstellungen
                        Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: Text("Einstellungen", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dynamischer Page Indicator am unteren Rand
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Wir generieren für jede unserer 3 Seiten einen Punkt
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8.0,
                          // Der aktive Punkt wird breiter (wie eine Pille)
                          width: _currentPage == index ? 24.0 : 8.0,
                          decoration: BoxDecoration(
                            // Der aktive Punkt leuchtet in deinem Amber-Theme, die anderen sind gedimmt
                            color: _currentPage == index
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}