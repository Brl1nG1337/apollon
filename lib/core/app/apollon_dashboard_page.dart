import 'package:apollon/core/widgets/common/apollon_animated_background.dart';
import 'package:apollon/core/widgets/common/apollon_page_container.dart';
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
      body: ApollonPageContainer(child: ApollonAnimatedBackground()),
    );
  }
}
