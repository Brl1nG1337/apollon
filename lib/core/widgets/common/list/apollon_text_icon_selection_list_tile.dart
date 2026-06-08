import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApollonTextIconSelectionListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ApollonTextIconSelectionListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: isSelected
          ? colors
                .primaryContainer // Farbe für den aktiven Tab (z.B. hellblau/-grau)
          : Colors.transparent,
      child: ListTile(
        // Inhalt leicht nach innen rücken, damit es im Rechteck gut aussieht
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),

        leading: Icon(
          icon,
          color: isSelected
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: GoogleFonts.audiowide(
            fontWeight: isSelected ? FontWeight.w200 : FontWeight.w100,
            color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
            fontSize: 24
          ),
        ),
        onTap: onTap,

        // Wir zwingen das ListTile selbst, transparent zu sein, damit unser Container durchscheint
        tileColor: Colors.transparent,
        selectedTileColor: Colors.transparent,
      ),
    );
  }
}
