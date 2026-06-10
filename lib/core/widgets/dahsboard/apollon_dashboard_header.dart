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
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<DateTime>(
              stream: _timeStream,
              initialData: DateTime.now(),
              builder: (context, snapshot) {
                final now = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat('HH:mm').format(now),
                        style: GoogleFonts.audiowide(
                          fontSize: 84,
                          fontWeight: FontWeight.w400,
                          color: colors.onSurface,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: colors.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(now),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: colors.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(width: 20),

          // Settings Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApollonSettingsPage()),
                );
              },
              child: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
