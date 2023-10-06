import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardUtils {
  static void hideKeyboard(BuildContext context) => FocusScope.of(context).requestFocus(FocusNode());

  static Future<void> mediumImpact() async {
    await SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.mediumImpact',
    );
  }

  static Future<void> lightImpact() async {
    await SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.lightImpact',
    );
  }
}