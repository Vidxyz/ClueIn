import 'dart:ui';

class ConstantUtils {
  static const int MAX_GAME_CARDS = 21;
  static const int MAX_CARD_UNKNOWN_BY_ALL = 3; // Murder weapon, person and room

  static const int CELL_SIZE_DEFAULT = 50;
  static const int TICK_CROSS_DIAMETER = 25;
  static const double MARKING_DIAMETER = 13;
  static const int CELL_SIZE_HORIZONTAL_DEFAULT = 100;
  static const int HORIZONTAL_DIVIDER_SIZE_DEFAULT = 20;

  static const List<String> characterList = ["Scarlett", "Mustard", "White", "Green", "Peacock", "Plum"];
  static const List<String> weaponList = ["Dagger", "Candlestick", "Revolver", "Rope", "LeadPipe", "Wrench"];
  static const List<String> roomList = [
    "Hall", "Lounge", "DiningRoom", "Kitchen", "BallRoom", "Conservatory", "BilliardRoom", "Library", "Study"
  ];

  static const String tick = "Tick";
  static const String cross = "X";

  static const List<String> allEntitites = [...characterList, ...weaponList, ...roomList];

  static const Map<String, String> entityNameToDisplayNameMap = {
    "Scarlett": "Scarlett",
    "Mustard": "Mustard",
    "White": "White",
    "Green": "Green",
    "Peacock": "Peacock",
    "Plum": "Plum",
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

  static const int MAX_MARKINGS = 15;


  static const String SHARED_PREF_SAVED_IDS_KEY = "cluein_game_ids";
  static const String SHARED_PREF_SAVED_GAMES_KEY = "cluein_saved_game";

  static const int MAX_UNDO_STACK_SIZE = 10;

  static const String UNIQUE_NAME_DELIMITER = "_@@_";

  static const String appName = "ClueIn";
  static const String playStoreUrl = "https://google.ca";
  static const String appStoreUrl = "https://google.ca";
  static const String creatorIconPath = "assets/creator.jpg";

  static const String githubUrl = "https://github.com/Vidxyz/ClueIn";
  static const String githubIssuesUrl = "https://github.com/Vidxyz/ClueIn/issues";
  static const String githubIconPath = "assets/github_icon.png";


  static const Color primaryAppColor = Color(0xff733ddf);
}