import 'dart:convert';

import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/views/load_game/bloc/load_game_event.dart';
import 'package:cluein_app/src/views/load_game/bloc/load_game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadGameBloc extends Bloc<LoadGameEvent, LoadGameState> {

  final logger = Logger("LoadGameBloc");

  SembastRepository sembast;

  LoadGameBloc({
    required this.sembast,
  }) : super(LoadGameStateInitial()) {
    on<FetchSavedGames>(_fetchSavedGames);
    on<DeleteSavedGame>(_deleteSavedGame);
  }

  void _deleteSavedGame(DeleteSavedGame event, Emitter<LoadGameState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_${event.gameId}");

    final savedGameIds =  prefs.getStringList(ConstantUtils.SHARED_PREF_SAVED_IDS_KEY) ?? [];
    savedGameIds.remove(event.gameId);
    await prefs.setStringList(ConstantUtils.SHARED_PREF_SAVED_IDS_KEY, savedGameIds);
  }

  void _fetchSavedGames(FetchSavedGames event, Emitter<LoadGameState> emit) async {
    emit(LoadGameStateLoading());

    final List<String> savedGameIds =  (await sembast.readStringList(ConstantUtils.SHARED_PREF_SAVED_IDS_KEY)) ?? [];
    List<GameDefinition> savedGameDefinitions = await fetchSavedGames(savedGameIds);

    savedGameDefinitions.sort((a, b) => b.lastSaved.compareTo(a.lastSaved));
    emit(SavedGamesFetched(savedGames: savedGameDefinitions));

  }

  Future<List<GameDefinition>> fetchSavedGames(List<String> savedGameIds) async {
    return Future.wait(savedGameIds.map((element) async {
      final savedJson = (await sembast.getString("${ConstantUtils.SHARED_PREF_SAVED_GAMES_KEY}_$element")) ?? "{}";

      dynamic jsonResp = jsonDecode(savedJson);
      return GameDefinition.fromJson(jsonResp);
    }));
  }

}