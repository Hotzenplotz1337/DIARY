import 'package:flutter/material.dart';

class Settings {
  RangeValues range;
  String basal;
  String bolus;
  double morning;
  double noon;
  double evening;
  int relation;

  Settings({
    this.range,
    this.basal,
    this.bolus,
    this.morning,
    this.noon,
    this.evening,
    this.relation,
  });
}
