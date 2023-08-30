import 'dart:async';
import 'dart:math';

import 'package:cluein_app/src/views/shared_components/ads/bloc/ad_event.dart';
import 'package:cluein_app/src/views/shared_components/ads/bloc/ad_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class AdBloc extends Bloc<AdEvent, AdState> {

  Timer? _refreshAdTimer;

  final logger = Logger("AdBloc");

  AdBloc() : super(const InitialAdState()) {
    on<FetchNewAd>(_fetchNewAd);
    on<FetchAdUnitIds>(_fetchAdUnitIds);
    on<NoAdsRequiredAsUserIsPremium>(_noAdsRequiredAsUserIsPremium);
  }

  void dispose() {
    _refreshAdTimer?.cancel();
  }

  void _noAdsRequiredAsUserIsPremium(NoAdsRequiredAsUserIsPremium event, Emitter<AdState> emit) async {
    emit(const AdsDisabled());
  }

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }

  void _fetchNewAd(FetchNewAd event, Emitter<AdState> emit) async {
    final currentState = state;
    if (currentState is AdUnitIdFetched) {
      emit(
          NewAdLoadRequested(
            adUnitId: currentState.adUnitId,
            randomId: generateRandomString(32)
          )
      );
      _refreshAdTimer = Timer(const Duration(seconds: 60), () {
        add(const FetchNewAd());
      });
    }
    else if (currentState is NewAdLoadRequested) {
      emit(
          NewAdLoadRequested(
              adUnitId: currentState.adUnitId,
              randomId: generateRandomString(32)
          )
      );
      _refreshAdTimer = Timer(const Duration(seconds: 60), () {
        add(const FetchNewAd());
      });
    }
  }

  void _fetchAdUnitIds(FetchAdUnitIds event, Emitter<AdState> emit) async {
    emit(
        const AdUnitIdFetched(
            adUnitId: "abc124",
        )
    );
  }
}
