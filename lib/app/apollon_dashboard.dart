import 'package:apollon/core/apollon_constants.dart';
import 'package:apollon/widgets/apollon_dashboard_appbar.dart';
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
            ApollonDashboardAppbar(),
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/Apollon Background.png"),
                    fit: BoxFit.cover,
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
