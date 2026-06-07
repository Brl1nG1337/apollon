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
      backgroundColor: Colors.white70,
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
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                color: colors.surface,
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "apollon™",
                      style: GoogleFonts.audiowide(fontSize: 36),
                    ),
                    IconButton(onPressed: () => {}, icon: Icon(Icons.settings)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
