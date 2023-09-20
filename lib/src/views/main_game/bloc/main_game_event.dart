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

  const MainGameStateLoadInitial({
    required this.initialGame,
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
  });

  @override
  List<Object> get props => [
    initialGame,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
  ];
}

class MainGameStateChanged extends MainGameEvent {
  final GameDefinition initialGame;

  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final OperationStack<String> undoStack;
  final OperationStack<String> redoStack;

  const MainGameStateChanged({
    required this.initialGame,
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
    required this.undoStack,
    required this.redoStack,
  });

  @override
  List<Object> get props => [
    initialGame,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    undoStack,
    redoStack,
  ];
}


class UndoLastMove extends MainGameEvent {
  final GameDefinition initialGame;

  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final OperationStack<String> undoStack;
  final OperationStack<String> redoStack;

  const UndoLastMove({
    required this.initialGame,
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
    required this.undoStack,
    required this.redoStack,
  });

  @override
  List<Object> get props => [
    initialGame,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    undoStack,
    redoStack,
  ];
}

class RedoLastMove extends MainGameEvent {
  final GameDefinition initialGame;

  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final OperationStack<String> undoStack;
  final OperationStack<String> redoStack;

  const RedoLastMove({
    required this.initialGame,
    required this.charactersGameState,
    required this.weaponsGameState,
    required this.roomsGameState,
    required this.undoStack,
    required this.redoStack,
  });

  @override
  List<Object> get props => [
    initialGame,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    undoStack,
    redoStack,
  ];
}

