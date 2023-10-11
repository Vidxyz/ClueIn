import 'dart:ui';

import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:equatable/equatable.dart';

class GameSettings extends Equatable {
  final Color primaryColorSetting;
  final bool selectMultipleMarkingsAtOnceSetting;
  final bool hasMandatoryTutorialBeenShown;
  final ClueVersion clueVersionSetting;

  const GameSettings({
    required this.primaryColorSetting,
    required this.selectMultipleMarkingsAtOnceSetting,
    required this.hasMandatoryTutorialBeenShown,
    required this.clueVersionSetting,
  });

  @override
  List<Object?> get props => [
    primaryColorSetting,
    selectMultipleMarkingsAtOnceSetting,
    hasMandatoryTutorialBeenShown,
    clueVersionSetting,
  ];
}