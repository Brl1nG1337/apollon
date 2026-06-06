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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Apollon Background.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          children: [
            Row(children: [Text("apollon")]),
          ],
        ),
      ),
    );
  }
}
