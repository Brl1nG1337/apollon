import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ApollonAppBar extends StatelessWidget {
  const ApollonAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.menu)),
          IconButton(onPressed: () => {}, icon: Icon(Icons.home)),
          IconButton(onPressed: () => {}, icon: Icon(Icons.settings)),
        ],
      ),
    );
  }
}
