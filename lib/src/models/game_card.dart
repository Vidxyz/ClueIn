import 'package:cluein_app/src/models/game_player_card.dart';
import 'package:cluein_app/src/models/game_room_card.dart';
import 'package:cluein_app/src/models/game_weapon_card.dart';

abstract class GameCard {
  String cardName();

  static GameCard fromString(String s) {
    switch (s) {
      case "Scarlett":
        return Scarlett();
      case "Mustard" :
        return Mustard();
      case "White" :
        return White();
      case "Green" :
        return Green();
      case "Peacock" :
        return Peacock();
      case "Plum" :
        return Plum();

      case "Dagger" :
        return Dagger();
      case "Candlestick" :
        return Candlestick();
      case "Revolver" :
        return Revolver();
      case "Rope" :
        return Rope();
      case "LeadPipe" :
        return LeadPipe();
      case "Wrench" :
        return Wrench();

      case "Hall" :
        return Hall();
      case "Lounge" :
        return Lounge();
      case "DiningRoom" :
        return DiningRoom();
      case "Kitchen" :
        return Kitchen();
      case "BallRoom" :
        return BallRoom();
      case "Conservatory" :
        return Conservatory();
      case "BilliardRoom" :
        return BilliardRoom();
      case "Library" :
        return Library();
      case "Study" :
        return Study();

      default:
        return Scarlett();
    }
  }
}




