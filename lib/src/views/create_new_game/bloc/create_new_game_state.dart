import 'package:cluein_app/src/models/game_card.dart';
import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:equatable/equatable.dart';

abstract class CreateNewGameState extends Equatable {
  const CreateNewGameState();

  @override
  List<Object> get props => [];

}

class CreateNewGameStateInitial extends CreateNewGameState {}

class NewGameBeingSaved extends CreateNewGameState {
  const NewGameBeingSaved();
}

class NewGameSavedAndReadyToStart extends CreateNewGameState {
  final GameDefinition gameDefinition;

  const NewGameSavedAndReadyToStart({
    required this.gameDefinition,
  });

  @override
  List<Object> get props => [
    gameDefinition,
  ];
}

class NewGameDetailsModified extends CreateNewGameState {
  final String gameName;
  final int totalPlayers;
  final Map<int, String> playerNames;

  final List<GameCard> initialCards;
  final List<GameCard> publicInfoCards;

  const NewGameDetailsModified({
    required this.gameName,
    required this.totalPlayers,
    required this.playerNames,
    this.initialCards = const [],
    this.publicInfoCards = const [],
  });

  @override
  List<Object> get props => [
    gameName,
    totalPlayers,
    playerNames,
    initialCards,
    publicInfoCards,
  ];
}
