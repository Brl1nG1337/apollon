# Apollon Project Documentation

Apollon ist eine Flutter-basierte Smart-Home- und Dashboard-Anwendung, die speziell für den Betrieb auf einem Raspberry Pi mit einem 800x480px Touchdisplay optimiert ist.

## Architektur-Übersicht

Das Projekt folgt einer sauberen Trennung von Verantwortlichkeiten, inspiriert von **MVVM (Model-View-ViewModel)** und **Service-Pattern**.

### State Management
- **Provider**: Wird für das App-weite State-Management verwendet (z.B. `ApollonWeatherProvider`).
- **ChangeNotifier**: Dient als Bindeglied zwischen Business-Logik (Services) und der UI.

### Datenfluss
`UI (Widgets/Pages) <-> Provider (ChangeNotifier) <-> Service (API/Logic) <-> Modelle (Data)`

---

## Projektstruktur (`lib/`)

### `core/`
Das Herzstück der Anwendung, unterteilt in logische Schichten:

- **`app/`**: Enthält die Hauptseiten (Screens) der Anwendung.
  - `app_init_page.dart`: Initialisierungs-Screen (lädt Profile vom Backend).
  - `apollon_dashboard_page.dart`: Das Haupt-Dashboard.
  - `apollon_settings_page.dart`: Einstellungen der App.

- **`models/`**: Datenstrukturen (Plain Dart Classes).
  - `weather/`: Modelle für Wetterdaten und Vorhersagen.
  - `apollon_setting.dart`: Basis-Klasse für Einstellungen.

- **`services/`**: Enthält die Business-Logik und API-Kommunikation.
  - `apollon_weather_service.dart`: Holt Daten von Open-Meteo.
  - `settings/`: Verwaltet die Kommunikation mit dem Spring Boot Backend.

- **`providers/`**: Hält den Zustand der Anwendung und informiert die UI über Änderungen.
  - `apollon_weather_provider.dart`: Zentraler Provider für alle Wetter-bezogenen UI-Komponenten.

- **`widgets/`**: Wiederverwendbare UI-Komponenten.
  - `common/`: Allgemeine Komponenten.
    - `apollon_animated_background.dart`: Das dynamische Hintergrundsystem. Steuert Gradients, Himmelskörper und Wettereffekte basierend auf Provider-Daten.
    - `apollon_flying_clouds_layer.dart`: Realisiert die Wolkenanimation mittels eines zeitbasierten `AnimatedBuilder` für flüssige Bewegungen.
  - `dahsboard/`: Spezifische Widgets für das Dashboard.
    - `apollon_weather_dashboard_widget.dart`: Wetter, Vorhersage und Metriken.
    - `apollon_env_dashboard_widget.dart`: Sensor-Daten (Temperatur, Feuchtigkeit, VPD) und Lüftersteuerung.
    - `apollon_devices_dashboard_widget.dart`: Geräte-Status und Schnellzugriff.
    - `dashboard_widget_container.dart`: Die Basis für den Glassmorphismus-Look.

- **`util/`**: Hilfsfunktionen und technische Utilities (z.B. `CustomBoxShadow`).

- **`apollon_constants.dart`**: Zentrale Datei für globale Konstanten (Farben, Abstände, Radien).

---

## Dashboard-Layout (800x480px)

Das Dashboard ist für eine feste Auflösung optimiert und besteht aus:

1.  **Header**:
    *   Große Echtzeit-Uhr (`DateFormat('HH:mm')`).
    *   Aktuelles Datum in Deutsch.
    *   Schnellzugriff auf Einstellungen.
2.  **Widget-Reihe**: Drei gleich große Spalten (Expanded), die die Kernbereiche abdecken:
    *   **Wetter**: Live-Daten von Open-Meteo.
    *   **Umgebung**: Monitoring von Sensoren (z.B. Kinderzimmer oder Grow-Setup).
    *   **Geräte**: Statusübersicht wichtiger Smart-Home Komponenten.

---

## Wetter- & Hintergrundsystem

Ein Kernfeature von Apollon ist der atmosphärische Hintergrund, der aus mehreren Ebenen besteht:

1.  **Gradient-Layer**: Ein `AnimatedContainer` wechselt sanft zwischen Tag- (Blautöne) und Nachtfarben (Dunkelblau/Violett).
2.  **Himmelskörper-Layer**:
    *   **Bahn**: Die Himmelskörper folgen einer elliptischen Bahn mit dem Horizont exakt in der Mitte des Displays (`y = 240`).
    *   **Tag**: Eine animierte Lottie-Sonne geht links (`x=0`) auf und verschwindet abends rechts (`x=800`).
    *   **Nacht**: Zeitgleich mit dem Sonnenuntergang erscheint der Mond links (`x=0`) und wandert über Nacht nach rechts. Die SVG-Mondphase wird dabei korrekt berechnet.
3.  **Wolken-Layer (`ApollonFlyingCloudsLayer`)**:
    *   Erzeugt eine konfigurierbare Anzahl an Wolken (`cloudCount`).
    *   Nutzt einen zeitbasierten Fortschritt (`DateTime.now()`), damit die Wolken bei einem Rebuild (z.B. durch Provider-Updates) nicht springen, sondern kontinuierlich weiterfliegen.
4.  **Weather-Overlay**: Vollbild-Lottie-Animationen für Regen, Schnee oder Gewitter, die über den anderen Ebenen liegen.

---

## Datenmodell Highlights

### `ApollonLayeredWeatherResult`
Zentrales Modell für das Wetter-Dashboard. Es enthält:
- Aktuelle Wetterbedingungen (Temperatur, Feuchtigkeit, Wind).
- Astronomische Daten (Sonnenfortschritt, Mondphase).
- Animierte Layer-Informationen (Wolkenanzahl, Regen-Overlay).
- `hourlyForecast`: Eine Liste von `HourlyForecast` Objekten für die 5-Stunden-Vorschau.

---

## Design & UI-Prinzipien

- **Glassmorphismus**: Starker Einsatz von `BackdropFilter` (Blur), niedriger Opazität und subtilen Rahmen (`DashboardWidgetContainer`).
- **Cyber-Aesthetic**: Nutzung von Google Fonts wie *Audiowide* für Titel und *Plus Jakarta Sans* für Inhalte.
- **Optimiert für Touch**: Große Interaktionsflächen und ein Layout, das auf 800x480px ohne Scrolling auskommt (bzw. auf die Displaygröße optimiert ist).
- **Dark Mode**: Die App ist auf ein dunkles, warmes Farbschema (`Color(0xFF100A00)`) mit Amber-Akzenten (`Color(0xFFFFB000)`) ausgelegt.

## Infrastruktur & Deployment

- **Raspberry Pi**: Native Ausführung auf Linux.
- **Backend**: Erwartet ein Spring Boot Backend für die Konfigurationsverwaltung (Settings).
- **API**: Nutzt Open-Meteo für kostenlose, lizenzfreie Wetterdaten.
