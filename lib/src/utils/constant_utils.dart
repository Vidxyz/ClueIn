class ConstantUtils {
  static const int MAX_GAME_CARDS = 21;
  static const int MAX_CARD_UNKNOWN_BY_ALL = 3; // Murder weapon, person and room

  static const int CELL_SIZE_DEFAULT = 75;
  static const int HORIZONTAL_DIVIDER_SIZE_DEFAULT = 20;

  static const List<String> characterList = ["Scarlett", "Mustard", "White", "Green", "Peacock", "Plum"];
  static const List<String> weaponList = ["Dagger", "Candlestick", "Revolver", "Rope", "LeadPipe", "Wrench"];
  static const List<String> roomList = [
    "Hall", "Lounge", "DiningRoom", "Kitchen", "BallRoom", "Conservatory", "BilliardRoom", "Library", "Study"
  ];

  static const String tick = "Tick";
  static const String cross = "X";

  static const List<String> allEntitites = [...characterList, ...weaponList, ...roomList];

  static const int MAX_MARKINGS = 20;


  static const String SHARED_PREF_SAVED_IDS_KEY = "cluein_game_ids";
  static const String SHARED_PREF_SAVED_GAMES_KEY = "cluein_saved_game";

  static const int MAX_UNDO_STACK_SIZE = 10;
}