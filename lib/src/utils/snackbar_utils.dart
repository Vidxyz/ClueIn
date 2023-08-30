import 'package:flutter/material.dart';

class SnackbarUtils {

  static const Duration shortDuration = Duration(milliseconds: 1500);
  static const Duration mediumDuration = Duration(milliseconds: 2500);

  static void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  static void showSnackBarMedium(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: mediumDuration,));
  }

  static void showSnackBarShort(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: shortDuration,));
  }
}