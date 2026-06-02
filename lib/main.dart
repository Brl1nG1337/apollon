import 'package:apollon/widgets/apollon_app_container.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ApollonApplication());
}

class ApollonApplication extends StatelessWidget {
  const ApollonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apollon',
      home: AppWrapper(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 2. Das ColorScheme aus einer Seed-Farbe generieren
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF143109), // Deine Wunsch-Hauptfarbe
          brightness: Brightness.dark, // Hell oder Dunkel definieren
        ),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ApollonAppContainer(),
    );
  }
}
