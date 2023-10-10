import 'dart:ui';

import 'package:equatable/equatable.dart';

class GameSettings extends Equatable {
  final Color primaryColorSetting;
  final bool selectMultipleMarkingsAtOnceSetting;

  const GameSettings({
    required this.primaryColorSetting,
    required this.selectMultipleMarkingsAtOnceSetting
  });

  @override
  List<Object?> get props => [
    primaryColorSetting,
    selectMultipleMarkingsAtOnceSetting
  ];
}