import 'package:flutter/material.dart';

class ApollonPageContainer extends StatelessWidget {
  final Widget child;

  const ApollonPageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: 800,
            height: 480,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
