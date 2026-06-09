import 'package:apollon/core/widgets/common/apollon_animated_background.dart';
import 'package:apollon/core/widgets/common/apollon_page_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: ApollonPageContainer(
        child: Stack(
          children: [
            ApollonAnimatedBackground(),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                _getGreeting(),
                style: GoogleFonts.audiowide(
                  fontSize: 48,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return "Guten Morgen, Basti!";
    } else if (hour >= 12 && hour < 18) {
      return "Guten Tag, Basti!";
    } else if (hour >= 18 && hour < 23) {
      return "Guten Abend, Basti!";
    } else {
      return "Hallo, Basti!";
    }
  }
}
