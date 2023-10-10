import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class FetchSettings extends SettingsEvent {
  const FetchSettings();

  @override
  List<Object> get props => [];
}

class SettingsUpdated extends SettingsEvent {
  final int primaryColor;
  final bool selectMultipleMarkingsAtOnce;

  const SettingsUpdated({
    required this.primaryColor,
    required this.selectMultipleMarkingsAtOnce,
  });

  @override
  List<Object> get props => [
    primaryColor,
    selectMultipleMarkingsAtOnce,
  ];
}