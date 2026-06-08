import 'package:flutter/material.dart';
import 'apollon_text_icon_selection_list_tile.dart'; // Pfad anpassen

class ApollonTextIconSelectionList extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<String> titles;
  final List<IconData> icons;

  const ApollonTextIconSelectionList({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.titles,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return ApollonTextIconSelectionListTile(
          title: titles[index],
          icon: icons[index],
          isSelected: index == selectedIndex,
          onTap: () => onTabSelected(index),
        );
      },
    );
  }
}