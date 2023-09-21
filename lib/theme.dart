import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorConstants {
  static const Color offWhite = Color(0xfff0f0f0);
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color disabled = Color.fromRGBO(0, 0, 0, 0.38);
  static const Color border = Color.fromRGBO(0, 0, 0, 0.12);
  static const Color overlay = Color.fromRGBO(0, 0, 0, 0.75);
  static const Color lightOverlay = Color.fromRGBO(0, 0, 0, 0.35);
  static const Color borderLight = Color.fromRGBO(255, 255, 255, 0.12);
  static const Color primary900Red = Color.fromRGBO(173, 33, 47, 1);
  static const Color primary900Green = Color.fromRGBO(51, 98, 88, 1);
  static const Color primary900Blue = Color.fromRGBO(0, 64, 142, 1);
  static const Color primary800Red = Color.fromRGBO(193, 53, 61, 1);
  static const Color primary800Green = Color.fromRGBO(67, 114, 104, 1);
  static const Color primary800Blue = Color.fromRGBO(0, 82, 163, 1);
  static const Color primary700Red = Color.fromRGBO(213, 72, 75, 1);
  static const Color primary700Teal = Color.fromRGBO(0, 120, 100, 1);
  static const Color primary700Green = Color.fromRGBO(82, 131, 120, 1);
  static const Color primary700Blue = Color.fromRGBO(0, 101, 185, 1);
  static const Color primary600Red = Color.fromRGBO(233, 90, 91, 1);
  static const Color primary600Green = Color.fromRGBO(99, 147, 136, 1);
  static const Color primary600Blue = Color.fromRGBO(0, 121, 207, 1);
  static const Color primary500Red = Color.fromRGBO(253, 108, 106, 1);
  static const Color primary500Green = Color.fromRGBO(115, 164, 153, 1);
  static const Color primary500Teal = Color.fromRGBO(0, 150, 136, 1);
  static const Color primary500Blue = Color.fromRGBO(0, 141, 230, 1);
  static const Color primary400Red = Color.fromRGBO(255, 125, 122, 1);
  static const Color primary400Green = Color.fromRGBO(132, 182, 170, 1);
  static const Color primary400Blue = Color.fromRGBO(0, 162, 253, 1);
  static const Color primary300Red = Color.fromRGBO(255, 143, 139, 1);
  static const Color primary300Teal = Color.fromRGBO(0, 170, 150, 1);
  static const Color primary300Green = Color.fromRGBO(149, 199, 187, 1);
  static const Color primary300Blue = Color.fromRGBO(62, 183, 255, 1);
  static const Color primary200Red = Color.fromRGBO(255, 161, 156, 1);
  static const Color primary200Green = Color.fromRGBO(166, 217, 205, 1);
  static const Color primary200Blue = Color.fromRGBO(95, 205, 255, 1);
  static const Color primary100Red = Color.fromRGBO(255, 179, 173, 1);
  static const Color primary100Green = Color.fromRGBO(184, 236, 223, 1);
  static const Color primary100Blue = Color.fromRGBO(124, 227, 255, 1);
  static const Color primary50Red = Color.fromRGBO(255, 198, 190, 1);
  static const Color primary50Green = Color.fromRGBO(202, 254, 241, 1);
  static const Color primary50Blue = Color.fromRGBO(151, 250, 255, 1);
  static const Color textLightPrimary = Color.fromRGBO(255, 255, 255, 1);
  static const Color textLightSecondary = Color.fromRGBO(171, 171, 171, 1);
  static const Color textDarkPrimary = Color.fromRGBO(51, 51, 51, 1);
  static const Color textDarkSecondary = Color.fromRGBO(136, 136, 136, 1);
  static const Color successMain = Color.fromRGBO(26, 162, 81, 1);
  static const Color successDark = Color.fromRGBO(26, 162, 81, 1);
  static const Color successLight = Color.fromRGBO(106, 231, 156, 1);
  static const Color warningMain = Color.fromRGBO(222, 165, 0, 1);
  static const Color warningDark = Color.fromRGBO(171, 104, 0, 1);
  static const Color warningLight = Color.fromRGBO(255, 220, 72, 1);
  static const Color errorMain = Color.fromRGBO(235, 0, 21, 1);
  static const Color errorDark = Color.fromRGBO(199, 0, 17, 1);
  static const Color errorLight = Color.fromRGBO(255, 153, 162, 1);

  static const Color disabledTextColor = Color(0xff6b717e);

  static const Color lightBackgroundColor = Color.fromRGBO(251, 251, 255, 1);
  static const Color darkBackgroundColor = Color.fromRGBO(17, 17, 20, 1);
  static const Color shadowColor = Color.fromRGBO(50, 50, 71, 0.08);

  // Special app colours
  static const Color videoCall = Colors.red;
  static const Color fbColor = Color(0xff3c5a9a);
  static const Color ratingBG = Color.fromRGBO(253, 216, 53, 1);
  static const Color starYellow = Color(0xFFfa6400);

  static const redOrangeGradient = LinearGradient(
    colors: [
      Color(0xFFD73763),
      Color(0xFFF6935C),
    ],
  );
  static const blueGradient = LinearGradient(
    colors: [
      Color(0xFF3790E3),
      Color(0xFF43CBE9),
    ],
  );
}

final BorderRadius radius = BorderRadius.circular(6.0);

final ThemeData appTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: ColorConstants.lightBackgroundColor,
    primaryColor: ColorConstants.primary500Teal,
    primaryColorDark: ColorConstants.primary700Teal,
    primaryColorLight: ColorConstants.primary300Teal,
    brightness: Brightness.light,
    backgroundColor: ColorConstants.lightBackgroundColor,

    colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: ConstantUtils.primaryAppColor,
      primaryVariant: ColorConstants.primary400Red,

      secondary: ConstantUtils.primaryAppColor,
      secondaryVariant: const Color(0xff018786),

      surface: Colors.white,
      background: ColorConstants.lightBackgroundColor,

      error: const Color(0xffb00020),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),

    ///appBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
      elevation: 0.0,
      toolbarTextStyle: TextStyle(
        color: ColorConstants.darkBackgroundColor,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
    ),

    ///text theme
    iconTheme: ThemeData.light().iconTheme.copyWith(
      color: ColorConstants.textLightPrimary,
    ),
    primaryIconTheme: ThemeData.light().iconTheme.copyWith(
        color: ColorConstants.primary500Teal
    ),

    unselectedWidgetColor: ColorConstants.textDarkPrimary,
    indicatorColor: ColorConstants.primary500Teal,
    chipTheme: ThemeData.light().chipTheme.copyWith(
      backgroundColor: ColorConstants.black,
      selectedColor: ColorConstants.white,
      disabledColor: Colors.grey,
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      secondarySelectedColor: Colors.white,
      brightness: Brightness.light,
    ),
    // textSelectionTheme: ThemeData.light().textSelectionTheme.copyWith(
    //   cursorColor,
    //   selectionColor,
    //   selectionHandleColor,
    // ),
    inputDecorationTheme: ThemeData.light().inputDecorationTheme.copyWith(
      // labelStyle,
      // floatingLabelStyle,
      // helperStyle,
      // helperMaxLines,

      // hintStyle: ThemeData.light().inputDecorationTheme.hintStyle!.copyWith(
      //   color: ColorConstants.primary400Red,
      // ),

      // errorStyle,
      // errorMaxLines,
      // floatingLabelBehavior = FloatingLabelBehavior.auto,
      // isDense: false,
      // contentPadding,
      // isCollapsed: false,
      iconColor: ColorConstants.primary500Teal,
      // prefixStyle,
      // prefixIconColor,
      // suffixStyle,
      // suffixIconColor,
      filled: false,
      // fillColor,
      // focusColor,
      // hoverColor,
    )
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: ColorConstants.darkBackgroundColor,
  primaryColor: ColorConstants.primary500Teal,
  primaryColorDark: ColorConstants.primary700Teal,
  primaryColorLight: ColorConstants.primary300Teal,
  brightness: Brightness.dark,
  backgroundColor: ColorConstants.darkBackgroundColor,

  colorScheme: ThemeData.dark().colorScheme.copyWith(
    primary: ColorConstants.primary500Teal,
    primaryVariant: ColorConstants.primary400Red,

    secondary: const Color(0xff03dac6),
    secondaryVariant: const Color(0xff018786),

    surface: Colors.white,
    background: ColorConstants.darkBackgroundColor,

    error: const Color(0xffb00020),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
    ),
    foregroundColor: Colors.white,
    toolbarTextStyle: TextStyle(
      color: ColorConstants.lightBackgroundColor,
      fontSize: 18.0,
      fontWeight: FontWeight.w800,
    ),
  ),

  ///text theme
  iconTheme: ThemeData.dark().iconTheme.copyWith(
    color: ColorConstants.textLightPrimary,
  ),
  primaryIconTheme: ThemeData.dark().iconTheme.copyWith(
    color: ColorConstants.primary500Teal,
  ),

  unselectedWidgetColor: ColorConstants.textLightPrimary,
  indicatorColor: ColorConstants.primary500Teal,
  chipTheme: ThemeData.light().chipTheme.copyWith(
    backgroundColor: ColorConstants.black,
    selectedColor: ColorConstants.white,
    disabledColor: Colors.grey,
    labelStyle: const TextStyle(color: Colors.white),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    secondarySelectedColor: Colors.white,
    brightness: Brightness.light,
  ),

);

/**
 * textTheme defaults
 *
 * FIELD                 SIZE  WEIGHT  SPACING
 * headline1             96.0  light   -1.5
 * headline2             60.0  light   -0.5
 * headline3             48.0  regular  0.0
 * headline4             34.0  regular  0.25
 * headline5             24.0  regular  0.0
 * headline6             20.0  medium   0.15
 * subtitle1             16.0  regular  0.15
 * subtitle2             14.0  medium   0.1
 * body1 | bodyText1     16.0  regular  0.5
 * body2 | bodyText2     14.0  regular  0.25
 * button                14.0  medium   1.25
 * caption               12.0  regular  0.4
 * overline              10.0  regular  1.5
 *
 */

// Primary colour candidate - #ff009688
