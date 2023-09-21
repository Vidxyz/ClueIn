import 'package:flutter/material.dart';

class ScreenUtils {
  static double getMinimumScreenWidth() => 392;

  static bool isPortraitOrientation(BuildContext context) => MediaQuery.of(context).orientation == Orientation.portrait;

  static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}