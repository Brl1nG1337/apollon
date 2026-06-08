import 'dart:core';

import 'package:apollon/core/widgets/common/apollon_page_container.dart';
import 'package:apollon/core/widgets/common/list/apollon_text_icon_selection_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/model/apollon_setting.dart';
import '../core/model/apollon_settings_category.dart';
import '../core/model/enums/settings/apollon_setting_type.dart';
import '../core/services/settings/apollon_settings_manager.dart';
import '../core/services/settings/apollon_settings_service.dart';
import '../core/widgets/common/apollon_basic_app_bar.dart';

class ApollonSettingsPage extends StatefulWidget {
  const ApollonSettingsPage({super.key});

  @override
  State<ApollonSettingsPage> createState() => _ApollonSettingsPageState();
}

class _ApollonSettingsPageState extends State<ApollonSettingsPage> {
  int current_tab = 0;
  final ApollonSettingsService _settingsService = ApollonSettingsService();

  // Hilfsmethode: Übersetzt den Icon-String aus der DB in ein echtes Material-Icon
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'settings_rounded':
        return Icons.settings_rounded;
      case 'devices_other_rounded':
        return Icons.devices_other_rounded;
      case 'network_wifi_3_bar_outlined':
        return Icons.network_wifi_3_bar_outlined;
      case 'cloud':
        return Icons.cloud;
      default:
        return Icons.tune_rounded; // Flexibler Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Daten direkt aus dem beim Start befüllten Manager ziehen
    final profile = ApollonSettingsManager().currentProfile;

    // Dynamisch die Listen aus den geladenen Backend-Kategorien generieren
    final List<String> tabTitles = profile?.categories.map((c) => c.name).toList() ?? [];
    final List<IconData> tabIcons = profile?.categories.map((c) => _getIconData(c.iconName)).toList() ?? [];

    // Fallback falls das Profil unerwartet leer sein sollte
    if (profile == null || profile.categories.isEmpty) {
      return const ApollonPageContainer(
        child: Center(child: Text("Keine Konfigurationsprofile geladen.")),
      );
    }

    // Die aktuell ausgewählte Kategorie ermitteln
    final currentCategory = profile.categories[current_tab];

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
                      titles: tabTitles,
                      icons: tabIcons,
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
                    padding: const EdgeInsets.all(24.0),
                    child: _buildTabContent(currentCategory, profile.name),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Erwartet nun das dynamische Kategorie-Objekt
  Widget _buildTabContent(ApollonSettingsCategory category, String profileName) {
    final colors = Theme.of(context).colorScheme;

    // Wir generieren die Liste der Einstellungsfelder dynamisch aus der DB-Struktur
    Widget content;

    if (category.settings.isEmpty) {
      content = Center(
        key: ValueKey("empty_${category.id}"),
        child: Text(
          "Keine Einstellungen in dieser Kategorie vorhanden.",
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    } else {
      content = ListView.builder(
        // Jede Kategorie bekommt eine eigene ValueKey basierend auf der ID für den Switcher
        key: ValueKey("cat_${category.id}"),
        itemCount: category.settings.length,
        itemBuilder: (context, index) {
          final setting = category.settings[index];
          return _buildSettingRow(setting, profileName);
        },
      );
    }

    // Deine flüssige Wechsel-Animation bleibt komplett erhalten
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.02),
              end: Offset.zero,
            ).animate(
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

  // Baut das passende UI-Element (Switch oder Textfeld) basierend auf dem Typ des Settings
  Widget _buildSettingRow(ApollonSetting setting, String profileName) {
    final colors = Theme.of(context).colorScheme;

    if (setting.type == ApollonSettingType.boolean) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SwitchListTile(
          title: Text(setting.label, style: GoogleFonts.audiowide(fontSize: 16)),
          value: setting.value as bool,
          activeColor: colors.primary,
          contentPadding: EdgeInsets.zero,
          onChanged: (bool newValue) async {
            // 1. Lokales Modell im Speicher updaten
            final updatedSetting = ApollonSetting(
              id: setting.id,
              key: setting.key,
              label: setting.label,
              value: newValue,
              type: setting.type,
            );

            // 2. Ans Backend senden
            final success = await _settingsService.updateSetting(profileName, updatedSetting);
            if (success) {
              setState(() {
                // UI neu zeichnen, indem wir den Wert im Cache ersetzen
                final index = ApollonSettingsManager()
                    .currentProfile!
                    .categories[current_tab]
                    .settings
                    .indexWhere((s) => s.key == setting.key);
                ApollonSettingsManager().currentProfile!.categories[current_tab].settings[index] = updatedSetting;
              });
            }
          },
        ),
      );
    }

    // Für String, Int und Double zeigen wir ein sauberes Text-Eingabefeld
    final controller = TextEditingController(text: setting.value.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              setting.label,
              style: GoogleFonts.audiowide(fontSize: 16, color: colors.onSurface),
            ),
          ),
          Expanded(
            flex: 4,
            child: TextField(
              controller: controller,
              keyboardType: setting.type == ApollonSettingType.string
                  ? TextInputType.text
                  : const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save_rounded),
                  onPressed: () async {
                    dynamic typedValue = controller.text;

                    // Typ-Rückwandlung vor dem Senden ans Backend
                    if (setting.type == ApollonSettingType.int) {
                      typedValue = int.tryParse(controller.text) ?? setting.value;
                    } else if (setting.type == ApollonSettingType.double) {
                      typedValue = double.tryParse(controller.text) ?? setting.value;
                    }

                    final updatedSetting = ApollonSetting(
                      id: setting.id,
                      key: setting.key,
                      label: setting.label,
                      value: typedValue,
                      type: setting.type,
                    );

                    final success = await _settingsService.updateSetting(profileName, updatedSetting);
                    if (success) {
                      // Cache aktualisieren
                      final index = ApollonSettingsManager()
                          .currentProfile!
                          .categories[current_tab]
                          .settings
                          .indexWhere((s) => s.key == setting.key);
                      ApollonSettingsManager().currentProfile!.categories[current_tab].settings[index] = updatedSetting;

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${setting.label} gespeichert!'), duration: const Duration(seconds: 1)),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}