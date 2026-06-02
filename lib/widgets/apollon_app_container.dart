import 'package:apollon/widgets/apollon_app_bar.dart';
import 'package:flutter/material.dart';

class ApollonAppContainer extends StatefulWidget {
  const ApollonAppContainer({super.key});

  @override
  State<ApollonAppContainer> createState() => _ApollonAppContainerState();
}

class _ApollonAppContainerState extends State<ApollonAppContainer> {

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      width: 480,
      height: 320,
      color: theme.colorScheme.surface.withAlpha(230),
      child: Column(
        children: [
          ApollonAppBar()
        ],
      ),
    );
  }
}
