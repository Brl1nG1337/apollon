import 'package:apollon/core/app/apollon_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:intl/intl.dart';

class ApollonDashboardHeader extends StatefulWidget {
  const ApollonDashboardHeader({super.key});

  @override
  State<ApollonDashboardHeader> createState() => _ApollonDashboardHeaderState();
}

class _ApollonDashboardHeaderState extends State<ApollonDashboardHeader> {
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Zentrierter Container für Uhrzeit und Datum
      child: Stack(
        alignment: Alignment.center,
        children: [
          StreamBuilder<DateTime>(
            stream: _timeStream,
            initialData: DateTime.now(),
            builder: (context, snapshot) {
              final now = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat('HH:mm').format(now),
                        style: GoogleFonts.audiowide(
                          fontSize: 110,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(now),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Settings Icon (am rechten Rand)
          Positioned(
            right: 8,
            top: 12,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApollonSettingsPage()),
                );
              },
              child: const Icon(FlutterIcons.md_settings_ion, color: Colors.white, size: 42),
            ),
          ),
        ],
      ),
    );
  }
}
