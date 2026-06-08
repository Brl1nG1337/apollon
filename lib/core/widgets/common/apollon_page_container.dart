import 'package:flutter/material.dart';

class ApollonPageContainer extends StatelessWidget {
  final Widget child;

  const ApollonPageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: 800,
        height: 480,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: child,
      ),
    );
  }
}
