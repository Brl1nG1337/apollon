import 'package:flutter/material.dart';

class ApollonCelestialPosition {
  final double left;
  final double top;

  ApollonCelestialPosition(this.left, this.top);

  Offset toOffset() => Offset(left, top);
}
