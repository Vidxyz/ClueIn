import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
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
    while (sembast.db == null) {
      print("Loop");
    }
    final primaryColorSetting =
    int.parse((await sembast.getString(ConstantUtils.SETTING_PRIMARY_COLOR)) ?? ConstantUtils.primaryAppColor.value.toString());

    emit(
        HomePageSettingsFetched(
          primaryColor: primaryColorSetting,
        )
    );
  }

}