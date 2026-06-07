import 'dart:async'; // Wichtig für den Timer!
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApollonDashboardAppbar extends StatefulWidget {
  const ApollonDashboardAppbar({super.key});

  @override
  State<ApollonDashboardAppbar> createState() => _ApollonDashboardAppbarState();
}

class _ApollonDashboardAppbarState extends State<ApollonDashboardAppbar> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Startet einen Timer, der jede Sekunde die UI aktualisiert
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    // Wichtig: Timer abbrechen, wenn das Widget zerstört wird (Memory Leak Schutz)
    _timer?.cancel();
    super.dispose();
  }

  // Hilfsmethode, um die Uhrzeit schön zu formatieren (hh:mm:ss)
  String _formatTime(DateTime time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    var colors = Theme.of(context).colorScheme;

    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        color: colors.surface,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8), // Padding fixiert
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Apollon™",
                  style: GoogleFonts.audiowide(fontSize: 36),
                ),
              ),
              const VerticalDivider(
                color: Colors.white,
                indent: 10,
                endIndent: 10,
                width: 20,
              ),
              // Hier wird die live tickende Uhrzeit angezeigt
              Text(
                _formatTime(_currentTime),
                style: GoogleFonts.audiowide(fontSize: 32),
              ),
              const VerticalDivider(
                color: Colors.white,
                indent: 10,
                endIndent: 10,
                width: 20,
              ),
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.settings, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}