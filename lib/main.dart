import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app/app_init_page.dart';
import 'core/providers/apollon_weather_provider.dart';
import 'core/providers/dashboard_expansion_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere Datumsformate für Deutsch
  await initializeDateFormatting('de_DE', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApollonWeatherProvider()),
        ChangeNotifierProvider(create: (context) => DashboardExpansionProvider()),
      ],
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
    );
  }
}
