import 'package:equatable/equatable.dart';

abstract class AdState extends Equatable {
  const AdState();

  @override
  List<Object> get props => [];

}

class InitialAdState extends AdState {
  const InitialAdState();

  @override
  List<Object> get props => [];

}

class AdsDisabled extends AdState {

  const AdsDisabled();

  @override
  List<Object> get props => [];

}

class AdUnitIdFetched extends AdState {
  final String adUnitId;

  const AdUnitIdFetched({required this.adUnitId});

  @override
  List<Object> get props => [adUnitId,];

}

class NewAdLoadRequested extends AdState {
  final String adUnitId;
  // This is there to force a refresh/reload because between state changes nothing else changes
  final String randomId;

  const NewAdLoadRequested({
    required this.adUnitId,
    required this.randomId,
  });

  @override
  List<Object> get props => [adUnitId, randomId];

}