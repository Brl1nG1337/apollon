import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/app/app_init_page.dart';
import 'core/providers/apollon_weather_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere Datumsformate für Deutsch
  await initializeDateFormatting('de_DE', null);

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
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
    // Sättigungs-Matrix: 1.0 ist normal, >1.0 ist vibrant
    // Ein Wert von 1.4 entspricht etwa dem NVIDIA "Digital Vibrance" Effekt
    const double saturation = 1.4;
    const double lumR = 0.212671;
    const double lumG = 0.715160;
    const double lumB = 0.072169;
    const double invV = 1.0 - saturation;
    const double r = invV * lumR;
    const double g = invV * lumG;
    const double b = invV * lumB;

    const List<double> saturationMatrix = <double>[
      r + saturation, g, b, 0, 0,
      r, g + saturation, b, 0, 0,
      r, g, b + saturation, 0, 0,
      0, 0, 0, 1, 0,
    ];

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(saturationMatrix),
      child: MaterialApp(
        title: 'Apollon',
        home: const AppInitPage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFB000),
            primary: const Color(0xFFFFB000),
            secondary: const Color(0xFFFF7A00),
            tertiary: const Color(0xFFFFD166),
            surface: const Color(0xFF100A00),
            onSurface: const Color(0xFFFFD89A),
            brightness: Brightness.dark,
          ),
          cardTheme: const CardThemeData(
            color: Color(0x1AFFFFFF),
            elevation: 0,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Color(0xFFFFD89A), fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: Color(0xFFFFD89A)),
            bodyMedium: TextStyle(color: Color(0xB3FFD89A)),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFFFFB000),
            size: 24,
          ),
        ),
      ),
    );
  }
}
