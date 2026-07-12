import 'dart:core';

import 'package:apollon/core/widgets/common/apollon_page_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/apollon_setting.dart';
import '../models/apollon_settings_category.dart';
import '../models/enums/settings/apollon_setting_type.dart';
import '../services/settings/apollon_settings_manager.dart';
import '../services/settings/apollon_settings_service.dart';

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
        child: Material(
          type: MaterialType.transparency,
          child: Center(child: Text("Keine Konfigurationsprofile geladen.")),
        ),
      );
    }

    // Die aktuell ausgewählte Kategorie ermitteln
    final currentCategory = profile.categories[current_tab];

    return ApollonPageContainer(
      // HIER IST DER FIX: Ein Material-Widget als direkter Child des Containers
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Neuer nativer Header mit Zurück-Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 24.0, 16.0), // Padding links leicht reduziert für den Button
              child: Row(
                children: [
                  // Zurück-Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: colors.onSurface,
                    iconSize: 28,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.settings_suggest_rounded, size: 32, color: colors.primary),
                  const SizedBox(width: 16),
                  Text(
                    "Einstellungen",
                    style: GoogleFonts.audiowide(
                      fontSize: 28,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant.withOpacity(0.5)),

            Expanded(
              child: Row(
                children: [
                  // Linke Seite: Native Menüführung (Flex 4)
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: colors.surfaceContainerLow,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: tabTitles.length,
                        itemBuilder: (context, index) {
                          final isSelected = current_tab == index;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              selected: isSelected,
                              selectedTileColor: colors.primaryContainer,
                              leading: Icon(
                                tabIcons[index],
                                color: isSelected
                                    ? colors.onPrimaryContainer
                                    : colors.onSurfaceVariant,
                              ),
                              title: Text(
                                tabTitles[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? colors.onPrimaryContainer
                                      : colors.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  current_tab = index;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Rechte Seite: Dynamischer Inhalt mit Animation (Flex 9)
                  Expanded(
                    flex: 9,
                    child: Container(
                      color: colors.surface,
                      padding: const EdgeInsets.all(32.0),
                      child: _buildTabContent(currentCategory, profile.name),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Erwartet nun das dynamische Kategorie-Objekt
  Widget _buildTabContent(ApollonSettingsCategory category, String profileName) {
    final colors = Theme.of(context).colorScheme;

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
        key: ValueKey("cat_${category.id}"),
        itemCount: category.settings.length,
        itemBuilder: (context, index) {
          final setting = category.settings[index];
          return _buildSettingRow(setting, profileName);
        },
      );
    }

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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save_rounded),
                  color: colors.primary,
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
                      final index = ApollonSettingsManager()
                          .currentProfile!
                          .categories[current_tab]
                          .settings
                          .indexWhere((s) => s.key == setting.key);
                      ApollonSettingsManager().currentProfile!.categories[current_tab].settings[index] = updatedSetting;

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${setting.label} gespeichert!'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
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