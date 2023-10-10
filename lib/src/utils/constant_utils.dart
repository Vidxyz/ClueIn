import 'dart:ui';

import 'package:flutter/material.dart';

class ConstantUtils {
  static const double WEB_APP_MAX_WIDTH = 600;

  static const int MAX_GAME_CARDS = 21;
  static const int MAX_CARD_UNKNOWN_BY_ALL = 3; // Murder weapon, person and room

  static const int CELL_SIZE_DEFAULT = 50;
  static const int TICK_CROSS_DIAMETER = 12;
  static const double MARKING_DIAMETER = 16;
  static const double MARKING_ICON_DIAMETER = 12;
  static const double MARKING_ICON_DIAMETER_2 = 24;
  static const int CELL_SIZE_HORIZONTAL_DEFAULT = 48;
  static const int HORIZONTAL_DIVIDER_SIZE_DEFAULT = 20;

  static const List<String> characterList = ["Scarlett", "Mustard", "White", "Green", "Peacock", "Plum"];
  static const List<String> weaponList = ["Dagger", "Candlestick", "Revolver", "Rope", "LeadPipe", "Wrench"];
  static const List<String> roomList = [
    "Hall", "Lounge", "DiningRoom", "Kitchen", "BallRoom", "Conservatory", "BilliardRoom", "Library", "Study"
  ];

  static const String tick = "Tick";
  static const String cross = "X";
  static const String questionMark = "?";
  static const String noOneHasThis = "*";

  static const List<String> quickMarkers = [tick, cross, questionMark];

  static const List<String> allEntitites = [...characterList, ...weaponList, ...roomList];

  static const Map<String, String> entityNameToDisplayNameMap = {
    "Scarlett": "Ms. Scarlett",
    "Mustard": "Col. Mustard",
    "White": "Mrs. White",
    "Green": "Mr. Green",
    "Peacock": "Mrs. Peacock",
    "Plum": "Prof. Plum",
    "Dagger" : "Dagger",
    "Candlestick" : "Candlestick",
    "Revolver" : "Revolver",
    "Rope" : "Rope",
    "LeadPipe" : "Lead Pipe",
    "Wrench" : "Wrench",
    "Hall" : "Hall",
    "Lounge" : "Lounge",
    "DiningRoom" : "Dining Room",
    "Kitchen" : "Kitchen",
    "BallRoom" : "Ball Room",
    "Conservatory" : "Conservatory",
    "BilliardRoom" : "Billiards Room",
    "Library" : "Library",
    "Study" : "Study",
  };

  static const int MAX_MARKINGS = 12;


  static const String SHARED_PREF_SAVED_IDS_KEY = "cluein_game_ids";
  static const String SHARED_PREF_SAVED_GAMES_KEY = "cluein_saved_game";

  static const String SETTING_PRIMARY_COLOR = "cluein_app_primary_color";
  static const String SETTING_CLUE_VERSION = "cluein_app_flavor";
  static const String SETTING_MULTIPLE_MARKINGS_AT_ONCE = "cluein_app_multiple_markings_at_once";

  static const int MAX_UNDO_STACK_SIZE = 20;

  static const String UNIQUE_NAME_DELIMITER = "_@@_";

  static const String appName = "ClueIn";
  static const String playStoreUrl = "https://google.ca";
  static const String appStoreUrl = "https://google.ca";
  static const String creatorIconPath = "assets/creator.jpg";

  static const String githubUrl = "https://github.com/Vidxyz/ClueIn";
  static const String githubIssuesUrl = "https://github.com/Vidxyz/ClueIn/issues";
  static const String githubIconPath = "assets/github_icon.png";

  static const int maxPlayerNameCharacters = 15;

  static const Color primaryAppColor = Color(0xff733ddf);
  // static const Color primaryAppColor = Color(0xff1aa328);

  static List<Color> cellBackgroundColorOptions = [
    Colors.grey.shade200,
    Colors.tealAccent.shade100,
    Colors.amberAccent.shade100,
    Colors.pinkAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.cyanAccent.shade100,
  ];
}