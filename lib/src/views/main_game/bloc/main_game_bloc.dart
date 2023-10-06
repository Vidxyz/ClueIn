import 'dart:convert';

import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/models/stack.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_event.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainGameBloc extends Bloc<MainGameEvent, MainGameState> {
  final logger = Logger("MainGameBloc");

  String? previousStateGlobal;

  SharedPrefsRepository sharedPrefs;

  MainGameBloc({
    required this.sharedPrefs,
  }) : super(MainGameStateInitial()) {
    on<MainGameStateChanged>(_mainGameStateChanged);
    on<MainGameStateLoadInitial>(_mainGameStateLoadInitial);
    on<UndoLastMove>(_undoLastMove);
    on<RedoLastMove>(_redoLastMove);
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
          charactersGameState: redoGameDefinition.charactersGameState,
          weaponsGameState: redoGameDefinition.weaponsGameState,
          roomsGameState: redoGameDefinition.roomsGameState,
          cellColoursState: redoGameDefinition.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final jsonStringToSave = gameToSave.toJson();
        await sharedPrefs.prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

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
          charactersGameState: redoGameDefinition.charactersGameState,
          weaponsGameState: redoGameDefinition.weaponsGameState,
          roomsGameState: redoGameDefinition.roomsGameState,
          cellColoursState: redoGameDefinition.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final jsonStringToSave = gameToSave.toJson();
        await sharedPrefs.prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

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
          charactersGameState: undoGameDefinition.charactersGameState,
          weaponsGameState: undoGameDefinition.weaponsGameState,
          roomsGameState: undoGameDefinition.roomsGameState,
          cellColoursState: undoGameDefinition.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final jsonStringToSave = gameToSave.toJson();
        await sharedPrefs.prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);


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
          charactersGameState: undoGameDefinition.charactersGameState,
          weaponsGameState: undoGameDefinition.weaponsGameState,
          roomsGameState: undoGameDefinition.roomsGameState,
          cellColoursState: undoGameDefinition.cellColoursState,
          lastSaved: DateTime.now(),
        );
        final jsonStringToSave = gameToSave.toJson();
        await sharedPrefs.prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

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
      lastSaved: DateTime.now(),
    );
    final jsonStringToSave = currentGameToSave.toJson();
    await sharedPrefs.prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);


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
      newStack.push(previousStateGlobal!);
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
