import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app/apollon_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const options = WindowOptions(
    fullScreen: true,
  );

  await windowManager.waitUntilReadyToShow(
    options,
        () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

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

