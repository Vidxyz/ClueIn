import 'package:cluein_app/src/models/game_card.dart';

abstract class GamePlayerCard extends GameCard {}

class Scarlett extends GamePlayerCard {
  @override
  String cardName() => "Scarlett";
}
class Mustard extends GamePlayerCard {
  @override
  String cardName() => "Mustard";
}
class White extends GamePlayerCard {
  @override
  String cardName() => "White";
}
class Green extends GamePlayerCard {
  @override
  String cardName() => "Green";
}
class Peacock extends GamePlayerCard {
  @override
  String cardName() => "Peacock";
}
class Plum extends GamePlayerCard {
  @override
  String cardName() => "Plum";
}