import 'dart:convert';

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

  String? previousState;

  MainGameBloc() : super(MainGameStateInitial()) {
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
          lastSaved: DateTime.now(),
        );
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final jsonStringToSave = gameToSave.toJson();
        await prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

        emit(
            MainGameStateModified(
              charactersGameState: redoGameDefinition.charactersGameState,
              weaponsGameState: redoGameDefinition.weaponsGameState,
              roomsGameState: redoGameDefinition.roomsGameState,
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
          lastSaved: DateTime.now(),
        );
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final jsonStringToSave = gameToSave.toJson();
        await prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

        emit(
            MainGameStateModified(
              charactersGameState: redoGameDefinition.charactersGameState,
              weaponsGameState: redoGameDefinition.weaponsGameState,
              roomsGameState: redoGameDefinition.roomsGameState,
              undoStack: newUndoStack,
              redoStack: newRedoStack,
            )
        );
      }
    }
  }

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
          lastSaved: DateTime.now(),
        );
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final jsonStringToSave = gameToSave.toJson();
        await prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

        emit(
            MainGameStateModified(
              charactersGameState: undoGameDefinition.charactersGameState,
              weaponsGameState: undoGameDefinition.weaponsGameState,
              roomsGameState: undoGameDefinition.roomsGameState,
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
          lastSaved: DateTime.now(),
        );
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final jsonStringToSave = gameToSave.toJson();
        await prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);

        emit(
            MainGameStateModified(
              charactersGameState: undoGameDefinition.charactersGameState,
              weaponsGameState: undoGameDefinition.weaponsGameState,
              roomsGameState: undoGameDefinition.roomsGameState,
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
      lastSaved: DateTime.now(),
    );

    previousState = gameToSave.toJson();
    emit(const DummyState());
    emit(
        MainGameStateModified(
          charactersGameState: event.charactersGameState,
          weaponsGameState: event.weaponsGameState,
          roomsGameState: event.roomsGameState,
          undoStack: OperationStack<String>([]),
          redoStack: OperationStack<String>([]),
        )
    );
  }

  void _mainGameStateChanged(MainGameStateChanged event, Emitter<MainGameState> emit) async {
    final gameToSave = GameDefinition(
      gameId: event.initialGame.gameId,
      gameName: event.initialGame.gameName,
      totalPlayers: event.initialGame.totalPlayers,
      playerNames: event.initialGame.playerNames,
      initialCards: event.initialGame.initialCards,
      charactersGameState: event.charactersGameState,
      weaponsGameState: event.weaponsGameState,
      roomsGameState: event.roomsGameState,
      lastSaved: DateTime.now(),
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonStringToSave = gameToSave.toJson();
    await prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.initialGame.gameId}", jsonStringToSave);


    if (event.undoStack.list.length < ConstantUtils.MAX_UNDO_STACK_SIZE) {
      final newStack = OperationStack(event.undoStack.list);
      newStack.push(previousState!);
      previousState = jsonStringToSave;
      emit(const DummyState());
      emit(
          MainGameStateModified(
            charactersGameState: event.charactersGameState,
            weaponsGameState: event.weaponsGameState,
            roomsGameState: event.roomsGameState,
            undoStack: newStack,
            redoStack: event.redoStack,
          )
      );
    }
    else {
      final newStack = OperationStack(event.undoStack.list);
      newStack.drain();
      newStack.push(previousState!);
      previousState = jsonStringToSave;
      emit(const DummyState());
      emit(
          MainGameStateModified(
            charactersGameState: event.charactersGameState,
            weaponsGameState: event.weaponsGameState,
            roomsGameState: event.roomsGameState,
            undoStack: newStack,
            redoStack: event.redoStack,
          )
      );
    }
  }

}
