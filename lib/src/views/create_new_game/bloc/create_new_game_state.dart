import 'package:cluein_app/src/models/game_card.dart';
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
  final String gameId;
  final int totalPlayers;
  final Map<int, String> playerNames;
  final List<GameCard> initialCards;

  const NewGameSavedAndReadyToStart({
    required this.gameId,
    required this.totalPlayers,
    required this.playerNames,
    required this.initialCards,
  });

  @override
  List<Object> get props => [
    totalPlayers,
    playerNames,
    initialCards,
  ];
}

class NewGameDetailsModified extends CreateNewGameState {
  final String gameName;
  final int totalPlayers;
  final Map<int, String> playerNames;

  final List<GameCard> initialCards;

  const NewGameDetailsModified({
    required this.gameName,
    required this.totalPlayers,
    required this.playerNames,
    this.initialCards = const [],
  });

  @override
  List<Object> get props => [
    gameName,
    totalPlayers,
    playerNames,
    initialCards,
  ];
}
