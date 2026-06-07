import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApollonSettings extends StatelessWidget {
  const ApollonSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          "Einstellungen",
          style: GoogleFonts.audiowide(fontSize: 24),
        ),
      ),
      body: Center(
        child: Text(
          "Apollon™ Konfiguration",
          style: TextStyle(color: colors.onBackground, fontSize: 18),
        ),
      ),
    );
  }
}