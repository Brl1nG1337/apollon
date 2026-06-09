import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/app/app_init_page.dart';
import 'core/providers/apollon_weather_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();

    await windowManager.ensureInitialized();

    const options = WindowOptions(fullScreen: true);

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApollonWeatherProvider(),
      child: const ApollonApplication(),
    ),
  );
}

class ApollonApplication extends StatelessWidget {
  const ApollonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apollon',
      home: const AppInitPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        // Das ColorScheme exakt nach deinen Vorgaben
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB000),
          primary: const Color(0xFFFFB000),
          secondary: const Color(0xFFFF7A00),
          tertiary: const Color(0xFFFFD166),
          surface: const Color(0xFF100A00), // Tiefes, warmes Schwarz/Braun
          onSurface: const Color(0xFFFFD89A), // Gut lesbarer, warmer Textton
          brightness: Brightness.dark,
        ),

        // Spezifische Anpassungen für Dashboard-Komponenten:

        // 1. Cards (für deine Sensor-Kacheln, Raum-Buttons etc.)
        cardTheme: const CardThemeData(
          color: Color(0x1AFFFFFF), // Minimal transparentes Weiß (ca. 10% Deckkraft)
          elevation: 0,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),

        // 2. Textelemente (Knackig und gut lesbar auf Distanz)
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFFFFD89A), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFFFFD89A)),
          bodyMedium: TextStyle(color: Color(0xB3FFD89A)), // 70% Deckkraft für sekundäre Infos
        ),

        // 3. Icons (Nutzen standardmäßig deinen edlen Amber-Ton)
        iconTheme: const IconThemeData(
          color: Color(0xFFFFB000),
          size: 24,
        ),
      ),
    );
  }
}
