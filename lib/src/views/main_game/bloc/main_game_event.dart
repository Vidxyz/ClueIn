import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:equatable/equatable.dart';

abstract class MainGameEvent extends Equatable {
  const MainGameEvent();

  @override
  List<Object> get props => [];
}

class MainGameStateChanged extends MainGameEvent {
  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  const MainGameStateChanged({
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
  });

  @override
  List<Object> get props => [
    charactersGameState,
    weaponsGameState,
    roomsGameState,
  ];
}

