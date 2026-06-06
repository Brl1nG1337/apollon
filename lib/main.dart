import 'package:apollon/app/apollon_app_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      fullScreen: true,
    ),
        () async {
      await windowManager.setFullScreen(true);
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
      home: ApollonAppWrapper(),
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

