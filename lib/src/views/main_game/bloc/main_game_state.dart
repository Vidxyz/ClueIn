import 'package:cluein_app/src/models/game_player_card.dart';
import 'package:cluein_app/src/models/game_room_card.dart';
import 'package:cluein_app/src/models/game_weapon_card.dart';
import 'package:cluein_app/src/models/stack.dart';
import 'package:equatable/equatable.dart';

/// GameState stored on a per card basis
/// Each card has a map associated with it
/// Each map element is a key-value pair of playerNames -> List of string markers
/// For example, a map could be
/// {
///    "Peacock" : {
///     "Player1Name": ["1", "2", "X"],
///     "Player2Name": ["?"],
///     "Player3Name": ["3"],
///    },
///    "Scarlett" : {
///     "Player1Name": ["X"],
///     "Player2Name": ["?"],
///     "Player3Name": ["3"],
///    }
///    ...
/// }
///
typedef CharacterName = String;
typedef PlayerName = String;
typedef GameState = Map<CharacterName, Map<PlayerName, List<String>>>;

abstract class MainGameState extends Equatable {
  const MainGameState();

  @override
  List<Object> get props => [];

}

class MainGameStateInitial extends MainGameState {}

class DummyState extends MainGameState {

  @override
  List<Object> get props => [];

  const DummyState();
}
class MainGameStateModified extends MainGameState {

  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final OperationStack<String> undoStack;
  final OperationStack<String> redoStack;

  const MainGameStateModified({
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
    required this.undoStack,
    required this.redoStack,
  });

  @override
  List<Object> get props => [
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    undoStack,
    redoStack,
  ];

  static GameState emptyCharactersGameState(List<String> playerNames) {
    return {
      Scarlett().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Mustard().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      White().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Green().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Peacock().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Plum().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
    };
  }

  static GameState emptyWeaponsGameState(List<String> playerNames) {
    return {
      Dagger().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Candlestick().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Revolver().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Rope().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      LeadPipe().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Wrench().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
    };
  }

  static GameState emptyRoomsGameState(List<String> playerNames) {
    return {
      Hall().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Lounge().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      DiningRoom().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Kitchen().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      BallRoom().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Conservatory().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      BilliardRoom().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Library().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
      Study().cardName() : Map.fromEntries(playerNames.map((e) => MapEntry(e, []))),
    };
  }
}
