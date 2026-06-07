import 'package:apollon/core/apollon_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApollonDashboard extends StatefulWidget {
  const ApollonDashboard({super.key});

  @override
  State<ApollonDashboard> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<ApollonDashboard> {
  @override
  Widget build(BuildContext context) {
    var colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: 800,
        height: 480,
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ApollonConstants.dashboardCornerRadius),
                  topRight: Radius.circular(ApollonConstants.dashboardCornerRadius),
                ),
                color: colors.surface,
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Apollon™", style: GoogleFonts.audiowide(fontSize: 36)),
                    IconButton(
                      onPressed: () => {},
                      icon: Icon(Icons.settings, size: 48),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/Apollon Background.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(ApollonConstants.dashboardCornerRadius),
                    bottomRight: Radius.circular(ApollonConstants.dashboardCornerRadius),
                  ),
                ),
                child: Column(children: []),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
