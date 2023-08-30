import 'package:cluein_app/src/models/game_card.dart';

abstract class GameRoomCard extends GameCard {}

class Hall extends GameRoomCard {
  @override
  String cardName() => "Hall";
}
class Lounge extends GameRoomCard {
  @override
  String cardName() => "Lounge";
}
class DiningRoom extends GameRoomCard {
  @override
  String cardName() => "DiningRoom";
}
class Kitchen extends GameRoomCard {
  @override
  String cardName() => "Kitchen";
}
class BallRoom extends GameRoomCard {
  @override
  String cardName() => "BallRoom";
}
class Conservatory extends GameRoomCard {
  @override
  String cardName() => "Conservatory";
}
class BilliardRoom extends GameRoomCard {
  @override
  String cardName() => "BilliardRoom";
}
class Library extends GameRoomCard {
  @override
  String cardName() => "Library";
}
class Study extends GameRoomCard {
  @override
  String cardName() => "Study";
}