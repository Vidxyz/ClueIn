import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:equatable/equatable.dart';

abstract class HomePageState extends Equatable {
  const HomePageState();

  @override
  List<Object> get props => [];

}

class HomePageStateInitial extends HomePageState {}

class HomePageSettingsLoading extends HomePageState {

  const HomePageSettingsLoading();
}

class HomePageSettingsFetched extends HomePageState {
  final GameSettings gameSettings;
  final int numberOfPreviouslySavedGames;

  const HomePageSettingsFetched({
    required this.gameSettings,
    required this.numberOfPreviouslySavedGames,
  });

  @override
  List<Object> get props => [
    gameSettings,
    numberOfPreviouslySavedGames,
  ];
}
