import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/public_transport_service.dart';
import '../dahsboard/dashboard_widget_container.dart';

class DashboardPublicTransportWidget extends StatefulWidget {
  final String fromId;
  final String toId;
  final String title;

  const DashboardPublicTransportWidget({
    super.key,
    required this.fromId,
    required this.toId,
    required this.title,
  });

  @override
  State<DashboardPublicTransportWidget> createState() => _DashboardPublicTransportWidgetState();
}

class _DashboardPublicTransportWidgetState extends State<DashboardPublicTransportWidget> {
  final PublicTransportService _transportService = PublicTransportService();
  TransportConnection? _currentConnection;
  Timer? _refreshTimer;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAbfahrt();

    // Automatisches Update alle 5 Minuten
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _loadAbfahrt();
    });
  }

  void _loadAbfahrt() async {
    try {
      final verbindung = await _transportService.fetchNextConnection(
        fromId: widget.fromId,
        toId: widget.toId,
        localTransportOnly: widget.title.contains("Bus"), // Filtert automatisch, wenn es ein Bus ist
      );

      if (mounted) {
        setState(() {
          _currentConnection = verbindung;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentConnection = null;
          _isInitialLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DashboardWidgetContainer(
      isLoading: _isInitialLoading,
      child: _currentConnection == null
          ? Center(
        child: Text(
          "Keine Verbindung",
          style: GoogleFonts.audiowide(fontSize: 16, color: colors.error),
        ),
      )
          : Stack(
        children: [
          // Titel der Route oben links (z.B. "DB Bielefeld")
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              widget.title,
              style: GoogleFonts.audiowide(
                fontSize: 18,
                letterSpacing: -1,
                color: colors.primary.withAlpha(220),
              ),
            ),
          ),

          // Transportmittel-Icon unten rechts
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              _currentConnection!.icon,
              size: 56,
              color: colors.tertiary.withAlpha(180),
            ),
          ),

          // Abfahrtszeit und Zusatz-Infos im Zentrum/Links
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Geplante Uhrzeit
                    Text(
                      _formatTime(_currentConnection!.plannedTime),
                      style: GoogleFonts.audiowide(
                        fontSize: 38,
                        letterSpacing: -2,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Verspätungs-Anzeige (Wird nur bei > 0 angezeigt)
                    if (_currentConnection!.delayInMinutes > 0)
                      Text(
                        "+${_currentConnection!.delayInMinutes}",
                        style: GoogleFonts.audiowide(
                          fontSize: 20,
                          color: Colors.redAccent,
                          height: 1.0,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Linienname & Gleis/Richtung (z.B. "RE 6 • Gl. 4" oder "Bus 21 • Pelkum")
                Text(
                  _currentConnection!.type == TransportType.train
                      ? "${_currentConnection!.lineName} • Gl. ${_currentConnection!.platform ?? '-'}"
                      : "${_currentConnection!.lineName} • ${_currentConnection!.direction ?? 'Bus'}",
                  style: GoogleFonts.audiowide(
                    fontSize: 14,
                    letterSpacing: -0.5,
                    color: colors.onSurface.withAlpha(200),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}