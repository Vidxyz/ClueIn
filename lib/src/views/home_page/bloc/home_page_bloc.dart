import 'dart:ui';

import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/views/home_page/bloc/home_page_event.dart';
import 'package:cluein_app/src/views/home_page/bloc/home_page_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {

  final logger = Logger("HomePageBloc");

  SembastRepository sembast;

  HomePageBloc({
    required this.sembast,
  }) : super(HomePageStateInitial()) {
    on<FetchHomePageSettings>(_fetchHomePageSettings);
  }

  void _fetchHomePageSettings(FetchHomePageSettings event, Emitter<HomePageState> emit) async {
    emit(const HomePageSettingsLoading());
    final primaryColorSetting =
      int.parse((await sembast.getString(ConstantUtils.SETTING_PRIMARY_COLOR)) ?? ConstantUtils.primaryAppColor.value.toString());
    final selectMultipleMarkingsAtOnceSetting =
      bool.parse((await sembast.getString(ConstantUtils.SETTING_MULTIPLE_MARKINGS_AT_ONCE) ?? "false"));

    final hasMandatoryTutorialBeenShown =
      bool.parse((await sembast.getString(ConstantUtils.SETTING_HAS_MANDATORY_TUTORIAL_BEEN_SHOWN) ?? "false"));

    final savedGameIds =  await sembast.readStringList(ConstantUtils.SHARED_PREF_SAVED_IDS_KEY) ?? [];

    emit(
        HomePageSettingsFetched(
          gameSettings: GameSettings(
            primaryColorSetting: Color(primaryColorSetting),
            selectMultipleMarkingsAtOnceSetting: selectMultipleMarkingsAtOnceSetting,
            hasMandatoryTutorialBeenShown: hasMandatoryTutorialBeenShown,
          ),
          numberOfPreviouslySavedGames: savedGameIds.length
        )
    );
  }

}