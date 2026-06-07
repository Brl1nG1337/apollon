import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum TransportType { bus, train, unknown }

class TransportConnection {
  final String lineName;
  final DateTime plannedTime;
  final int delayInMinutes;
  final String? platform;
  final String? direction;
  final TransportType type;

  TransportConnection({
    required this.lineName,
    required this.plannedTime,
    required this.delayInMinutes,
    this.platform,
    this.direction,
    required this.type,
  });

  IconData get icon {
    switch (type) {
      case TransportType.bus:
        return Icons.directions_bus_rounded;
      case TransportType.train:
        return Icons.directions_railway_filled_rounded;
      default:
        return Icons.commute_rounded;
    }
  }
}

class PublicTransportService {
  final String _baseApiUrl = "https://v6.db.transport.rest/journeys";

  Future<TransportConnection?> fetchNextConnection({
    required String fromId,
    required String toId,
    bool localTransportOnly = false, // Aktiviert den D-Ticket Filter für Busse
  }) async {
    try {
      // Base-Query mit dem neuen dbnav-Profil laut Dokumentation
      String urlString = "$_baseApiUrl?from=$fromId&to=$toId&results=1&profile=dbnav";

      if (localTransportOnly) {
        urlString += "&deutschlandTicketConnectionsOnly=true";
      }

      final url = Uri.parse(urlString);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List journeys = data['journeys'] ?? [];

        if (journeys.isNotEmpty) {
          final firstJourney = journeys[0];
          final List legs = firstJourney['legs'] ?? [];
          if (legs.isEmpty) return null;

          // Erstes Teilstück finden, das kein Fußweg ist
          final firstLeg = legs.firstWhere(
                (leg) => leg['mode'] != 'walk',
            orElse: () => legs[0],
          );

          final line = firstLeg['line'];
          final String lineName = line?['name'] ?? "ÖPNV";

          // Modus ermitteln
          final String modeStr = line?['mode'] ?? firstLeg['mode'] ?? "";
          TransportType type = TransportType.unknown;
          if (modeStr == "bus") type = TransportType.bus;
          if (modeStr == "train") type = TransportType.train;

          // Zeiten parsen (API nutzt primär plannedDeparture)
          final String? plannedDepartureStr = firstLeg['plannedDeparture'] ?? firstLeg['departure'];
          if (plannedDepartureStr == null) return null;
          final DateTime plannedTime = DateTime.parse(plannedDepartureStr).toLocal();

          // Verspätung abgleichen
          int delay = 0;
          final String? actualDepartureStr = firstLeg['departure'];
          if (actualDepartureStr != null && firstLeg['plannedDeparture'] != null) {
            final DateTime actualTime = DateTime.parse(actualDepartureStr).toLocal();
            delay = actualTime.difference(plannedTime).inMinutes;
            if (delay < 0) delay = 0;
          }

          final String? platform = firstLeg['plannedDeparturePlatform'] ?? firstLeg['platform'];
          final String? direction = firstLeg['direction'];

          return TransportConnection(
            lineName: lineName,
            plannedTime: plannedTime,
            delayInMinutes: delay,
            platform: platform,
            direction: direction,
            type: type,
          );
        }
      } else {
        print("Apollon ÖPNV-Fehler: Status ${response.statusCode}");
      }
    } catch (e) {
      print("Apollon ÖPNV-Fehler beim Parsen: $e");
    }
    return null;
  }
}