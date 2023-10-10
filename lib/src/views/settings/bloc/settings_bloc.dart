import 'dart:convert';

import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/views/settings/bloc/settings_event.dart';
import 'package:cluein_app/src/views/settings/bloc/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

// enum ClueVersion { Default }

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {

  final logger = Logger("LoadGameBloc");

  SembastRepository sembast;

  SettingsBloc({
    required this.sembast,
  }) : super(SettingsStateInitial()) {
    on<FetchSettings>(_fetchSettings);
    on<SettingsUpdated>(_settingsUpdated);
  }

  void _settingsUpdated(SettingsUpdated event, Emitter<SettingsState> emit) async {
    sembast.setString(ConstantUtils.SETTING_PRIMARY_COLOR, event.primaryColor.toString());
    sembast.setString(ConstantUtils.SETTING_MULTIPLE_MARKINGS_AT_ONCE, event.selectMultipleMarkingsAtOnce.toString());
  }

  void _fetchSettings(FetchSettings event, Emitter<SettingsState> emit) async {
    final primaryColorSetting =
        int.parse((await sembast.getString(ConstantUtils.SETTING_PRIMARY_COLOR)) ?? ConstantUtils.primaryAppColor.value.toString());
    // final clueVersionSetting  =
    //     ClueVersion.values.byName(((await sembast.getString(ConstantUtils.SETTING_CLUE_VERSION)) ?? ClueVersion.Default.name));
    final selectMultipleMarkingsAtOnceSetting =
      bool.parse((await sembast.getString(ConstantUtils.SETTING_MULTIPLE_MARKINGS_AT_ONCE) ?? "false"));

    emit(
        SettingsFetched(
          primaryColor: primaryColorSetting,
          // clueVersion: clueVersionSetting,
          selectMultipleMarkingsAtOnce: selectMultipleMarkingsAtOnceSetting,
        )
    );
  }

}