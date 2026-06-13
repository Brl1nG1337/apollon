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
          ApollonAnimatedBackground(),
          // defusor
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(color: Colors.black.withOpacity(0.15)),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "APOLLON-OS™",
                  style: GoogleFonts.audiowide(
                    height: 1,
                    fontSize: 48,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  _loadingText,
                  style: GoogleFonts.audiowide(
                    fontSize: 22,
                    color: Colors.white70,
                    decoration: TextDecoration.none,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                if (!_hasError)
                  CircularProgressIndicator(color: Colors.white)
                else
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 48),
                    color: colors.error,
                    onPressed: _loadAppDependencies,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
