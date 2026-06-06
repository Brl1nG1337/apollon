import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app/apollon_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (Platform.isLinux ||
          Platform.isWindows ||
          Platform.isMacOS)) {
    await windowManager.ensureInitialized();
  }

  runApp(const ApollonApplication());
}

class ApollonApplication extends StatelessWidget {
  const ApollonApplication({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apollon',
      home: ApollonDashboard(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 2. Das ColorScheme aus einer Seed-Farbe generieren
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4249), // Deine Wunsch-Hauptfarbe
          brightness: Brightness.dark, // Hell oder Dunkel definieren
        ),
      ),
    );
  }
}

