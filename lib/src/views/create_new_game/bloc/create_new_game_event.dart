import 'package:cluein_app/src/models/game_card.dart';
import 'package:equatable/equatable.dart';

abstract class CreateNewGameEvent extends Equatable {
  const CreateNewGameEvent();

  @override
  List<Object> get props => [];
}

class BeginNewClueGame extends CreateNewGameEvent {
  final String gameName;
  final int totalPlayers;
  final Map<int, String> playerNames;

  final List<GameCard> initialCards;
  final List<GameCard> publicInfoCards;

  const BeginNewClueGame({
    required this.gameName,
    required this.totalPlayers,
    required this.playerNames,
    required this.initialCards,
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

class NewGameDetailedChanged extends CreateNewGameEvent {
  final String gameName;
  final int totalPlayers;
  final Map<int, String> playerNames;

  final List<GameCard> initialCards;
  final List<GameCard> publicInfoCards;

  const NewGameDetailedChanged({
    required this.gameName,
    required this.totalPlayers,
    required this.playerNames,
    required this.initialCards,
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

