import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:equatable/equatable.dart';

abstract class LoadGameState extends Equatable {
  const LoadGameState();

  @override
  List<Object> get props => [];

}

class LoadGameStateInitial extends LoadGameState {}

class SavedGamesFetched extends LoadGameState {
  final List<GameDefinition> savedGames;

  const SavedGamesFetched({required this.savedGames});

  @override
  List<Object> get props => [savedGames];
}
