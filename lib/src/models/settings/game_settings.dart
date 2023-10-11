import 'dart:ui';

import 'package:equatable/equatable.dart';

class GameSettings extends Equatable {
  final Color primaryColorSetting;
  final bool selectMultipleMarkingsAtOnceSetting;
  final bool hasMandatoryTutorialBeenShown;

  const GameSettings({
    required this.primaryColorSetting,
    required this.selectMultipleMarkingsAtOnceSetting,
    required this.hasMandatoryTutorialBeenShown,
  });

  @override
  List<Object?> get props => [
    primaryColorSetting,
    selectMultipleMarkingsAtOnceSetting,
    hasMandatoryTutorialBeenShown,
  ];
}