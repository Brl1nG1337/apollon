import 'package:apollon/core/widgets/common/apollon_page_container.dart';
import 'package:apollon/core/widgets/common/list/apollon_text_icon_selection_list.dart';
import 'package:flutter/material.dart';

import '../core/widgets/common/apollon_basic_app_bar.dart';
// Importiere hier deinen AddDeviceScreen, den wir vorhin gebaut haben!

class ApollonSettingsPage extends StatefulWidget {
  const ApollonSettingsPage({super.key});

  @override
  State<ApollonSettingsPage> createState() => _ApollonSettingsPageState();
}

class _ApollonSettingsPageState extends State<ApollonSettingsPage> {
  int current_tab = 0;

  // Deine neuen, optimierten Tab-Definitionen
  final List<String> _tabTitles = ["Allgemein", "Geräte", "Netzwerk", "MQTT"];
  final List<IconData> _tabIcons = [
    Icons.settings_rounded,
    Icons.devices_other_rounded,
    Icons.network_wifi_3_bar_outlined,
    Icons.cloud,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ApollonPageContainer(
      child: Column(
        children: [
          const ApollonBasicAppBar(title: "Einstellungen"),
          Expanded(
            child: Row(
              children: [
                // Linke Seite: Menüführung (Flex 4)
                Expanded(
                  flex: 4,
                  child: Container(
                    color: colors.surfaceContainerLow,
                    child: ApollonTextIconSelectionList(
                      selectedIndex: current_tab,
                      titles: _tabTitles,
                      icons: _tabIcons,
                      onTabSelected: (index) {
                        setState(() {
                          current_tab = index;
                        });
                      },
                    ),
                  ),
                ),

                // Rechte Seite: Dynamischer Inhalt mit Animation (Flex 9)
                Expanded(
                  flex: 9,
                  child: Container(
                    color: colors.surface,
                    padding: const EdgeInsets.all(16.0),
                    child: _buildTabContent(current_tab),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Liefert den Inhalt zurück und verpackt ihn in eine weiche Transition
  Widget _buildTabContent(int tabIndex) {
    Widget content;

    // WICHTIG: Jedes Widget braucht eine eindeutige 'ValueKey',
    // damit der AnimatedSwitcher merkt, dass sich der Inhalt geändert hat!
    switch (tabIndex) {
      case 0:
        content = const Center(
          key: ValueKey("general"),
          child: Text("Allgemeine Apollon Konfigurationen"),
        );
        break;
      case 1:
        content = const Center(key: ValueKey("devices"), child: Text("Geräte verwalten"),);
        break;
      case 2:
        content = const Center(
          key: ValueKey("network"),
          child: Text("Netzwerk-Verbindungen & Pi-Status"),
        );
        break;
      case 3:
        content = const Center(
          key: ValueKey("mqtt"),
          child: Text("MQTT Broker & Datenstrom-Konfiguration"),
        );
        break;
      default:
        content = const SizedBox.shrink();
    }

    // Hier läuft die Magie für den Content-Wechsel
    // Hier läuft die Magie für den Content-Wechsel
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      // Kombinierter Fade-In & dezenter Slide-Up-Effekt
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.02), // Ein ganz feiner Hub von unten nach oben
              end: Offset.zero,
            ).animate(
              // SO ist es richtig: Wir übergeben ein CurvedAnimation-Objekt
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}