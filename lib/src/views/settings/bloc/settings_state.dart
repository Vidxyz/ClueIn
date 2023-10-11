import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/views/settings/bloc/settings_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];

}

class SettingsStateInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsFetched extends SettingsState {
  final int primaryColor;
  final ClueVersion clueVersion;
  final bool selectMultipleMarkingsAtOnce;
  final bool hasMandatoryTutorialBeenShown;

  const SettingsFetched({
    required this.primaryColor,
    required this.clueVersion,
    required this.selectMultipleMarkingsAtOnce,
    required this.hasMandatoryTutorialBeenShown,
  });

  @override
  List<Object> get props => [
    primaryColor,
    clueVersion,
    selectMultipleMarkingsAtOnce,
    hasMandatoryTutorialBeenShown,
  ];
}
