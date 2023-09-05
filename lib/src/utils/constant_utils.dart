class ConstantUtils {
  static const int MAX_GAME_CARDS = 21;
  static const int MAX_CARD_UNKNOWN_BY_ALL = 3; // Murder weapon, person and room

  static const int CELL_SIZE_DEFAULT = 50;
  static const int HORIZONTAL_DIVIDER_SIZE_DEFAULT = 20;

  static const List<String> characterList = ["Scarlett", "Mustard", "White", "Green", "Peacock", "Plum"];
  static const List<String> weaponList = ["Dagger", "Candlestick", "Revolver", "Rope", "Lead Pipe", "Wrench"];
  static const List<String> roomList = [
    "Hall", "Lounge", "DiningRoom", "Kitchen", "BallRoom", "Conservatory", "BilliardRoom", "Library", "Study"
  ];

  static const List<String> allEntitites = [...characterList, ...weaponList, ...roomList];


}