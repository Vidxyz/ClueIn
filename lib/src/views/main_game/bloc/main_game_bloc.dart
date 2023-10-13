import 'dart:convert';

import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/models/stack.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_event.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class MainGameBloc extends Bloc<MainGameEvent, MainGameState> {
  final logger = Logger("MainGameBloc");

  String? previousStateGlobal;

  SembastRepository sembast;

  MainGameBloc({
    required this.sembast,
  }) : super(MainGameStateInitial()) {
    on<PlayerNameChanged>(_playerNameChanged);
    on<MainGameStateChanged>(_mainGameStateChanged);
    on<MainGameStateLoadInitial>(_mainGameStateLoadInitial);
    on<UndoLastMove>(_undoLastMove);
    on<RedoLastMove>(_redoLastMove);
    on<GameOverEvent>(_gameOverEvent);
    on<MarkMandatoryTutorialAsComplete>(_markMandatoryTutorialAsComplete);
    on<GameNameChanged>(_gameNameChanged);
  }

  void _markMandatoryTutorialAsComplete(MarkMandatoryTutorialAsComplete event, Emitter<MainGameState> emit) async {
    final currentState = state;
    if (currentState is MainGameStateModified) {
      await sembast.setString(ConstantUtils.SETTING_HAS_MANDATORY_TUTORIAL_BEEN_SHOWN, "true");
      emit(const DummyState());
      emit(currentState);
    }
  }

  void _gameOverEvent(GameOverEvent event, Emitter<MainGameState> emit) async {
    final currentState = state;
    if (currentState is MainGameStateModified) {
      emit(const GameOverState());
      emit(currentState);
    }
  }

  void _redoLastMove(RedoLastMove event, Emitter<MainGameState> emit) async {
    if (event.redoStack.isNotEmpty) {
      final newRedoStack = OperationStack(event.redoStack.list);
      final nextState = newRedoStack.pop();

      // Ensure max size again
      if (event.undoStack.list.length < ConstantUtils.MAX_UNDO_STACK_SIZE) {
        final newUndoStack = OperationStack(event.undoStack.list);
        dynamic jsonResp = jsonDecode(nextState);
        final redoGameDefinition = GameDefinition.fromJson(jsonResp);
        emit(const DummyState());

        // push current state INSTEAD
        // Save game
        final currentGame = GameDefinition(
          gameId: event.initialGame.gameId,
          gameName: event.initialGame.gameName,
          totalPlayers: event.initialGame.totalPlayers,
          playerNames: event.initialGame.playerNames,
          initialCards: event.initialGame.initialCards,
          publicInfoCards: event.initialGame.publicInfoCards,
          charactersGameState: event.charactersGameState,
          weaponsGameState: event.weaponsGameState,
          roomsGameState: event.roomsGameState,
          cellColoursState: event.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final currentStateGame = currentGame.toJson();
        newUndoStack.push(currentStateGame);

        // Save game
        final gameToSave = GameDefinition(
          gameId: event.initialGame.gameId,
          gameName: event.initialGame.gameName,
          totalPlayers: event.initialGame.totalPlayers,
          playerNames: event.initialGame.playerNames,
          initialCards: event.initialGame.initialCards,
          publicInfoCards: event.initialGame.publicInfoCards,
          charactersGameState: redoGameDefinition.charactersGameState,
          weaponsGameState: redoGameDefinition.weaponsGameState,
          roomsGameState: redoGameDefinition.roomsGameState,
          cellColoursState: redoGameDefinition.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final jsonStringToSave = gameToSave.toJson();
        await sembast.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

        previousStateGlobal = jsonStringToSave;

        emit(
            MainGameStateModified(
              charactersGameState: redoGameDefinition.charactersGameState,
              weaponsGameState: redoGameDefinition.weaponsGameState,
              roomsGameState: redoGameDefinition.roomsGameState,
              cellColoursState: redoGameDefinition.cellColoursState,
              undoStack: newUndoStack,
              redoStack: newRedoStack,
            )
        );
      }
      else {
        final newUndoStack = OperationStack(event.undoStack.list);
        newUndoStack.drain();

        final currentGame = GameDefinition(
          gameId: event.initialGame.gameId,
          gameName: event.initialGame.gameName,
          totalPlayers: event.initialGame.totalPlayers,
          playerNames: event.initialGame.playerNames,
          initialCards: event.initialGame.initialCards,
          publicInfoCards: event.initialGame.publicInfoCards,
          charactersGameState: event.charactersGameState,
          weaponsGameState: event.weaponsGameState,
          roomsGameState: event.roomsGameState,
          cellColoursState: event.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final currentStateGame = currentGame.toJson();
        newUndoStack.push(currentStateGame);

        dynamic jsonResp = jsonDecode(nextState);
        final redoGameDefinition = GameDefinition.fromJson(jsonResp);
        emit(const DummyState());

        // Save game
        final gameToSave = GameDefinition(
          gameId: event.initialGame.gameId,
          gameName: event.initialGame.gameName,
          totalPlayers: event.initialGame.totalPlayers,
          playerNames: event.initialGame.playerNames,
          initialCards: event.initialGame.initialCards,
          publicInfoCards: event.initialGame.publicInfoCards,
          charactersGameState: redoGameDefinition.charactersGameState,
          weaponsGameState: redoGameDefinition.weaponsGameState,
          roomsGameState: redoGameDefinition.roomsGameState,
          cellColoursState: redoGameDefinition.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final jsonStringToSave = gameToSave.toJson();
        await sembast.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

        previousStateGlobal = jsonStringToSave;

        emit(
            MainGameStateModified(
              charactersGameState: redoGameDefinition.charactersGameState,
              weaponsGameState: redoGameDefinition.weaponsGameState,
              roomsGameState: redoGameDefinition.roomsGameState,
              cellColoursState: redoGameDefinition.cellColoursState,
              undoStack: newUndoStack,
              redoStack: newRedoStack,
            )
        );
      }
    }
  }


  // previousState - change it
  void _undoLastMove(UndoLastMove event, Emitter<MainGameState> emit) async {
    if (event.undoStack.isNotEmpty) {
      final newUndoStack = OperationStack(event.undoStack.list);
      final previousState = newUndoStack.pop();

      // Ensure max size again
      if (event.redoStack.list.length < ConstantUtils.MAX_UNDO_STACK_SIZE) {
        final newRedoStack = OperationStack(event.redoStack.list);
        // push current state INSTEAD
        // Save game
        final currentGame = GameDefinition(
          gameId: event.initialGame.gameId,
          gameName: event.initialGame.gameName,
          totalPlayers: event.initialGame.totalPlayers,
          playerNames: event.initialGame.playerNames,
          initialCards: event.initialGame.initialCards,
          publicInfoCards: event.initialGame.publicInfoCards,
          charactersGameState: event.charactersGameState,
          weaponsGameState: event.weaponsGameState,
          roomsGameState: event.roomsGameState,
          cellColoursState: event.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final currentStateGame = currentGame.toJson();

        newRedoStack.push(currentStateGame);
        dynamic jsonResp = jsonDecode(previousState);
        final undoGameDefinition = GameDefinition.fromJson(jsonResp);
        emit(const DummyState());

        // Save game
        final gameToSave = GameDefinition(
          gameId: event.initialGame.gameId,
          gameName: event.initialGame.gameName,
          totalPlayers: event.initialGame.totalPlayers,
          playerNames: event.initialGame.playerNames,
          initialCards: event.initialGame.initialCards,
          publicInfoCards: event.initialGame.publicInfoCards,
          charactersGameState: undoGameDefinition.charactersGameState,
          weaponsGameState: undoGameDefinition.weaponsGameState,
          roomsGameState: undoGameDefinition.roomsGameState,
          cellColoursState: undoGameDefinition.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final jsonStringToSave = gameToSave.toJson();
        await sembast.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);


        previousStateGlobal = jsonStringToSave;

        emit(
            MainGameStateModified(
              charactersGameState: undoGameDefinition.charactersGameState,
              weaponsGameState: undoGameDefinition.weaponsGameState,
              roomsGameState: undoGameDefinition.roomsGameState,
              cellColoursState: undoGameDefinition.cellColoursState,
              undoStack: newUndoStack,
              redoStack: newRedoStack,
            )
        );
      }
      else {
        final newRedoStack = OperationStack(event.redoStack.list);
        newRedoStack.drain();

        final currentGame = GameDefinition(
          gameId: event.initialGame.gameId,
          gameName: event.initialGame.gameName,
          totalPlayers: event.initialGame.totalPlayers,
          playerNames: event.initialGame.playerNames,
          initialCards: event.initialGame.initialCards,
          publicInfoCards: event.initialGame.publicInfoCards,
          charactersGameState: event.charactersGameState,
          weaponsGameState: event.weaponsGameState,
          roomsGameState: event.roomsGameState,
          cellColoursState: event.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final currentStateGame = currentGame.toJson();

        newRedoStack.push(currentStateGame);
        dynamic jsonResp = jsonDecode(previousState);
        final undoGameDefinition = GameDefinition.fromJson(jsonResp);
        emit(const DummyState());

        // Save game
        final gameToSave = GameDefinition(
          gameId: event.initialGame.gameId,
          gameName: event.initialGame.gameName,
          totalPlayers: event.initialGame.totalPlayers,
          playerNames: event.initialGame.playerNames,
          initialCards: event.initialGame.initialCards,
          publicInfoCards: event.initialGame.publicInfoCards,
          charactersGameState: undoGameDefinition.charactersGameState,
          weaponsGameState: undoGameDefinition.weaponsGameState,
          roomsGameState: undoGameDefinition.roomsGameState,
          cellColoursState: undoGameDefinition.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final jsonStringToSave = gameToSave.toJson();
        await sembast.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

        previousStateGlobal = jsonStringToSave;

        emit(
            MainGameStateModified(
              charactersGameState: undoGameDefinition.charactersGameState,
              weaponsGameState: undoGameDefinition.weaponsGameState,
              roomsGameState: undoGameDefinition.roomsGameState,
              cellColoursState: undoGameDefinition.cellColoursState,
              undoStack: newUndoStack,
              redoStack: newRedoStack,
            )
        );
      }
    }
  }


  void _mainGameStateLoadInitial(MainGameStateLoadInitial event, Emitter<MainGameState> emit) async {
    final gameToSave = GameDefinition(
      gameId: event.initialGame.gameId,
      gameName: event.initialGame.gameName,
      totalPlayers: event.initialGame.totalPlayers,
      playerNames: event.initialGame.playerNames,
      initialCards: event.initialGame.initialCards,
      publicInfoCards: event.initialGame.publicInfoCards,
      charactersGameState: event.charactersGameState,
      weaponsGameState: event.weaponsGameState,
      roomsGameState: event.roomsGameState,
      cellColoursState: event.cellColoursState,
      lastSaved: DateTime.now(),
    );

    previousStateGlobal = gameToSave.toJson();
    emit(const DummyState());
    emit(
        MainGameStateModified(
          charactersGameState: event.charactersGameState,
          weaponsGameState: event.weaponsGameState,
          roomsGameState: event.roomsGameState,
          cellColoursState: event.cellColoursState,
          undoStack: OperationStack<String>([]),
          redoStack: OperationStack<String>([]),
        )
    );
  }


  void _playerNameChanged(PlayerNameChanged event, Emitter<MainGameState> emit) async {
    final currentState = state;
    if (currentState is MainGameStateModified) {
      final currentGameToSave = GameDefinition(
        gameId: event.initialGame.gameId,
        gameName: event.initialGame.gameName,
        totalPlayers: event.initialGame.totalPlayers,
        playerNames: event.initialGame.playerNames,
        initialCards: event.initialGame.initialCards,
        charactersGameState: currentState.charactersGameState,
        weaponsGameState: currentState.weaponsGameState,
        roomsGameState: currentState.roomsGameState,
        cellColoursState: currentState.cellColoursState,
        publicInfoCards: event.initialGame.publicInfoCards,
        lastSaved: DateTime.now(),
      );
      final jsonStringToSave = currentGameToSave.toJson();
      await sembast.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

      previousStateGlobal = jsonStringToSave;

      emit(const DummyState());
      emit(
          MainGameStateModified(
            charactersGameState: currentState.charactersGameState,
            weaponsGameState: currentState.weaponsGameState,
            roomsGameState: currentState.roomsGameState,
            cellColoursState: currentState.cellColoursState,
            undoStack: OperationStack([]),
            redoStack: OperationStack([]),
          )
      );
    }
  }

  void _gameNameChanged(GameNameChanged event, Emitter<MainGameState> emit) async {
    final currentState = state;
    if (currentState is MainGameStateModified) {
      final currentGameToSave = GameDefinition(
        gameId: event.initialGame.gameId,
        gameName: event.initialGame.gameName,
        totalPlayers: event.initialGame.totalPlayers,
        playerNames: event.initialGame.playerNames,
        initialCards: event.initialGame.initialCards,
        charactersGameState: currentState.charactersGameState,
        weaponsGameState: currentState.weaponsGameState,
        roomsGameState: currentState.roomsGameState,
        cellColoursState: currentState.cellColoursState,
        publicInfoCards: event.initialGame.publicInfoCards,
        lastSaved: DateTime.now(),
      );
      final jsonStringToSave = currentGameToSave.toJson();
      await sembast.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);
    }
  }

  void _mainGameStateChanged(MainGameStateChanged event, Emitter<MainGameState> emit) async {
    final currentGameToSave = GameDefinition(
      gameId: event.initialGame.gameId,
      gameName: event.initialGame.gameName,
      totalPlayers: event.initialGame.totalPlayers,
      playerNames: event.initialGame.playerNames,
      initialCards: event.initialGame.initialCards,
      charactersGameState: event.charactersGameState,
      weaponsGameState: event.weaponsGameState,
      roomsGameState: event.roomsGameState,
      cellColoursState: event.gameBackgroundColorState,
      publicInfoCards: event.initialGame.publicInfoCards,
      lastSaved: DateTime.now(),
    );
    final jsonStringToSave = currentGameToSave.toJson();
    await sembast.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);


    if (event.undoStack.list.length < ConstantUtils.MAX_UNDO_STACK_SIZE) {
      final newStack = OperationStack(event.undoStack.list);
      if (previousStateGlobal != null) {
        newStack.push(previousStateGlobal!);
      }
      previousStateGlobal = jsonStringToSave;
      emit(const DummyState());
      emit(
          MainGameStateModified(
            charactersGameState: event.charactersGameState,
            weaponsGameState: event.weaponsGameState,
            roomsGameState: event.roomsGameState,
            cellColoursState: event.gameBackgroundColorState,
            undoStack: newStack,
            redoStack: OperationStack([]),
          )
      );
    }
    else {
      final newStack = OperationStack(event.undoStack.list);
      newStack.drain();
      if (previousStateGlobal != null) {
        newStack.push(previousStateGlobal!);
      }
      previousStateGlobal = jsonStringToSave;
      emit(const DummyState());
      emit(
          MainGameStateModified(
            charactersGameState: event.charactersGameState,
            weaponsGameState: event.weaponsGameState,
            roomsGameState: event.roomsGameState,
            cellColoursState: event.gameBackgroundColorState,
            undoStack: newStack,
            redoStack: OperationStack([]),
          )
      );
    }
  }

}
