import 'package:cluein_app/src/views/main_game/bloc/main_game_event.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class MainGameBloc extends Bloc<MainGameEvent, MainGameState> {
  final logger = Logger("MainGameBloc");

  MainGameBloc() : super(MainGameStateInitial()) {
    on<MainGameStateChanged>(_mainGameStateChanged);
  }

  void _mainGameStateChanged(MainGameStateChanged event, Emitter<MainGameState> emit) async {
    emit(
        MainGameStateModified(
          charactersGameState: event.charactersGameState,
          weaponsGameState: event.weaponsGameState,
          roomsGameState: event.roomsGameState,
        )
    );
  }

}
