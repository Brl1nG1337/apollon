import 'dart:ui';

import 'package:apollon/core/widgets/common/apollon_animated_background.dart';
import 'package:apollon/core/widgets/common/apollon_page_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/settings/apollon_settings_manager.dart';
import '../services/settings/apollon_settings_service.dart';
import 'apollon_dashboard_page.dart';

class AppInitPage extends StatefulWidget {
  const AppInitPage({super.key});

  @override
  State<AppInitPage> createState() => _AppInitPageState();
}

class _AppInitPageState extends State<AppInitPage> {
  final ApollonSettingsService _service = ApollonSettingsService();
  final ApollonSettingsManager _manager = ApollonSettingsManager();

  String _loadingText = "Initialisiere Apollon Core...";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAppDependencies();
  }

  Future<void> _loadAppDependencies() async {
    setState(() {
      _hasError = false;
      _loadingText = "Lade Einstellungs-Profile...";
    });

    try {
      // 1. API-Call an Spring Boot abfeuern
      final profile = await _service.fetchProfile("Default");

      // 2. Im globalen Manager speichern
      _manager.currentProfile = profile;

      // 3. Weiterleitung zur Hauptseite (ohne Zurück-Option)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ApollonDashboardPage()),
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _loadingText = "Verbindungsfehler zum Backend!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ApollonPageContainer(
      child: Stack(
        children: [
          const ApollonAnimatedBackground(),
          // Defusor
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(color: Colors.black.withOpacity(0.15)),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 300, // Begrenzt die Breite, damit der Ladebalken gut aussieht
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "APOLLON-OS™",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.audiowide(
                      height: 1,
                      fontSize: 48,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _loadingText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.audiowide(
                      fontSize: 18, // Leicht verkleinert, damit es harmonischer wirkt
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (!_hasError)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4), // Abgerundete Ecken für den Balken
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6, // Etwas dickerer, moderner Ladebalken
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 48),
                      color: colors.error,
                      onPressed: _loadAppDependencies,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}