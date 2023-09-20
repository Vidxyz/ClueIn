import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_new_game_event.dart';
import 'package:uuid/uuid.dart';

class CreateNewGameBloc extends Bloc<CreateNewGameEvent, CreateNewGameState> {
  final logger = Logger("CreateNewGameBloc");
  static const uuid = Uuid();


  CreateNewGameBloc() : super(CreateNewGameStateInitial()) {
    on<NewGameDetailedChanged>(_newGameDetailedChanged);
    on<BeginNewClueGame>(_beginNewClueGame);
  }

  void _newGameDetailedChanged(NewGameDetailedChanged event, Emitter<CreateNewGameState> emit) async {
    emit(
        NewGameDetailsModified(
            gameName: event.gameName,
            totalPlayers: event.totalPlayers,
            playerNames: event.playerNames,
            initialCards: event.initialCards,
        )
    );
  }

  // This will save current game to SharedPrefs, and then emit event to pop and send shared prefs ID
  void _beginNewClueGame(BeginNewClueGame event, Emitter<CreateNewGameState> emit) async {
    emit(const NewGameBeingSaved());
    final newGameId = uuid.v4();
    final gameToSave = GameDefinition(
        gameId: newGameId,
        gameName: event.gameName,
        totalPlayers: event.totalPlayers,
        playerNames: Map.fromEntries(event.playerNames.entries.map((e) => MapEntry(e.key, "${e.value}${ConstantUtils.UNIQUE_NAME_DELIMITER}${uuid.v4()}"))),
        initialCards: event.initialCards,
        lastSaved: DateTime.now(),
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final jsonStringToSave = gameToSave.toJson();
    final existingSavedGameIds = prefs.getStringList(ConstantUtils.SHARED_PREF_SAVED_IDS_KEY) ?? [];
    existingSavedGameIds.add(newGameId);
    await prefs.setStringList("cluein_game_ids", existingSavedGameIds);
    await prefs.setString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_$newGameId", jsonStringToSave);

    emit(
        NewGameSavedAndReadyToStart(
            gameDefinition: gameToSave
        )
    );
  }
}
