import 'dart:io';

import 'package:apollon/app/app_init_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app/apollon_dashboard_page.dart';

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

  runApp(const ApollonApplication());
}

class ApollonApplication extends StatelessWidget {
  const ApollonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apollon',
      home: AppInitPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 2. Das ColorScheme aus einer Seed-Farbe generieren
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB000),
          primary: const Color(0xFFFFB000),
          secondary: const Color(0xFFFF7A00),
          tertiary: const Color(0xFFFFD166),
          surface: const Color(0xFF100A00),
          onSurface: const Color(0xFFFFD89A),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
