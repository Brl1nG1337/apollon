import 'package:apollon/core/app/apollon_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat('HH:mm').format(now),
                        style: GoogleFonts.audiowide(
                          fontSize: 96,
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
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(now),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
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
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApollonSettingsPage()),
                  );
                },
                child: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
