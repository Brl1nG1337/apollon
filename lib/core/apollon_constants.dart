import 'package:flutter/foundation.dart';

class ApollonConstants {
  static final double dashboardCornerRadius = 100;

  // ── Backend-Konfiguration ──────────────────────────────────────────────────
  // Im Debug-Modus (lokale Entwicklung) wird localhost genutzt.
  // Im Release-Modus (Raspberry Pi) wird die feste IP des Backends genutzt.
  static const String _backendIp = '192.168.11.146';
  static const int _backendPort = 8080;

  static String get backendBaseUrl {
    if (kDebugMode) {
      return 'http://localhost:$_backendPort';
    }
    return 'http://$_backendIp:$_backendPort';
  }
}