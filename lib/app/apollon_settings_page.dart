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

  // Deine Tab-Definitionen (Daten)
  final List<String> _tabTitles = ["Allgemein", "Geräte", "Netzwerk", "MQTT"];
  final List<IconData> _tabIcons = [
    Icons.settings_rounded,
    Icons.devices_other_rounded,
    Icons.network_check_rounded,
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
                          current_tab = index; // Aktualisiert die UI bei Klick
                        });
                      },
                    ),
                  ),
                ),

                // Rechte Seite: Dynamischer Inhalt (Flex 9)
                Expanded(
                  flex: 11,
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

  // Diese Methode liefert je nach ausgewähltem Tab die passende UI zurück
  Widget _buildTabContent(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const Placeholder();
      case 1:
        return const Center(
          child: Text("MQTT Broker & Datenstrom-Einstellungen"),
        );
      case 2:
        return const Center(child: Text("Allgemeine Apollon Konfigurationen"));
      default:
        return const SizedBox.shrink();
    }
  }
}
