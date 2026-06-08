import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApollonBasicAppBar extends StatelessWidget {
  final bool showBackButton;
  final String title;

  const ApollonBasicAppBar({
    super.key,
    this.showBackButton = true,
    this.title = "",
  });

  @override
  Widget build(BuildContext context) {
    var colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: colors.secondary,
        boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.5))],
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 48,
                color: colors.onSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          Text(
            title,
            style: GoogleFonts.audiowide(
              fontSize: 42,
              color: colors.onSecondary,
              letterSpacing: -2,
              fontWeight: FontWeight.w400
            ),
          ),
        ],
      ),
    );
  }
}
