import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ApollonAppWrapper extends StatefulWidget {
  const ApollonAppWrapper({super.key});

  @override
  State<ApollonAppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<ApollonAppWrapper> {

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
              fit: BoxFit.cover
          ),
          borderRadius: BorderRadius.circular(50)
        ),
      ),
    );
  }
}
