import 'package:equatable/equatable.dart';

abstract class LoadGameEvent extends Equatable {
  const LoadGameEvent();

  @override
  List<Object> get props => [];
}

class FetchSavedGames extends LoadGameEvent {
  const FetchSavedGames();

  @override
  List<Object> get props => [];
}

class GameSelectedToLoad extends LoadGameEvent {
  final String selectedGameId;

  const GameSelectedToLoad({
    required this.selectedGameId
  });

  @override
  List<Object> get props => [selectedGameId];
}