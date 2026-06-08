import 'package:apollon/app/apollon_dashboard_page.dart';
import 'package:apollon/core/widgets/common/apollon_page_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/settings/apollon_settings_manager.dart';
import '../core/services/settings/apollon_settings_service.dart';

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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cooler Cyber-Titel passend zu deinen Tiles
            Text(
              "APOLLON OS™",
              style: GoogleFonts.audiowide(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 40),
            if (!_hasError)
              CircularProgressIndicator(color: colors.primary)
            else
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 40),
                color: colors.error,
                onPressed: _loadAppDependencies,
              ),
            const SizedBox(height: 20),
            Text(
              _loadingText,
              style: TextStyle(
                color: _hasError ? colors.error : colors.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
