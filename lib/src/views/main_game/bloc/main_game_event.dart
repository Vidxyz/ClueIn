import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/models/stack.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:equatable/equatable.dart';

abstract class MainGameEvent extends Equatable {
  const MainGameEvent();

  @override
  List<Object> get props => [];
}

class MainGameStateLoadInitial extends MainGameEvent {
  final GameDefinition initialGame;

  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final GameBackgroundColorState cellColoursState;

  const MainGameStateLoadInitial({
    required this.initialGame,
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
    required this.cellColoursState,
  });

  @override
  List<Object> get props => [
    initialGame,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    cellColoursState,
  ];
}

class MainGameStateChanged extends MainGameEvent {
  final GameDefinition initialGame;

  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final GameBackgroundColorState gameBackgroundColorState;

  final OperationStack<String> undoStack;
  final OperationStack<String> redoStack;

  const MainGameStateChanged({
    required this.initialGame,
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
    required this.gameBackgroundColorState,
    required this.undoStack,
    required this.redoStack,
  });

  @override
  List<Object> get props => [
    initialGame,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    gameBackgroundColorState,
    undoStack,
    redoStack,
  ];
}


class UndoLastMove extends MainGameEvent {
  final GameDefinition initialGame;

  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final GameBackgroundColorState cellColoursState;

  final OperationStack<String> undoStack;
  final OperationStack<String> redoStack;

  const UndoLastMove({
    required this.initialGame,
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
    required this.cellColoursState,
    required this.undoStack,
    required this.redoStack,
  });

  @override
  List<Object> get props => [
    initialGame,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    cellColoursState,
    undoStack,
    redoStack,
  ];
}

class RedoLastMove extends MainGameEvent {
  final GameDefinition initialGame;

  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final GameBackgroundColorState cellColoursState;

  final OperationStack<String> undoStack;
  final OperationStack<String> redoStack;

  const RedoLastMove({
    required this.initialGame,
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
    required this.cellColoursState,
    required this.undoStack,
    required this.redoStack,
  });

  @override
  List<Object> get props => [
    initialGame,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    cellColoursState,
    undoStack,
    redoStack,
  ];
}

class GameOverEvent extends MainGameEvent {

  const GameOverEvent();

  @override
  List<Object> get props => [];
}

class MarkMandatoryTutorialAsComplete extends MainGameEvent {

  const MarkMandatoryTutorialAsComplete();

  @override
  List<Object> get props => [];
}

class GameNameChanged extends MainGameEvent {
  final GameDefinition initialGame;

  const GameNameChanged({
    required this.initialGame,
  });

  @override
  List<Object> get props => [
    initialGame,
  ];
}


class PlayerNameChanged extends MainGameEvent {
  final GameDefinition initialGame;

  const PlayerNameChanged({
    required this.initialGame,
  });

  @override
  List<Object> get props => [
    initialGame,
  ];
}
