import 'package:flutter/material.dart';

class Responsive {
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 800;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 48;
    if (width >= 800) return 32;
    return 20;
  }
}
