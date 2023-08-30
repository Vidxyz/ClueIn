import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'create_new_game_event.dart';

class CreateNewGameBloc extends Bloc<CreateNewGameEvent, CreateNewGameState> {
  final logger = Logger("CreateNewGameBloc");

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

  }
}
