import 'package:cluein_app/src/models/game_card.dart';

abstract class GameWeaponCard extends GameCard {}

class Dagger extends GameWeaponCard {
  @override
  String cardName() => "Dagger";
}
class Candlestick extends GameWeaponCard {
  @override
  String cardName() => "Candlestick";
}
class Revolver extends GameWeaponCard {
  @override
  String cardName() => "Revolver";
}
class Rope extends GameWeaponCard {
  @override
  String cardName() => "Rope";
}
class LeadPipe extends GameWeaponCard {
  @override
  String cardName() => "LeadPipe";
}
class Wrench extends GameWeaponCard {
  @override
  String cardName() => "Wrench";
}