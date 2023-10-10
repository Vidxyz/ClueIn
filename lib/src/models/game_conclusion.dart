import 'package:equatable/equatable.dart';

class GameConclusion extends Equatable {
  final String? character;
  final String? weapon;
  final String? room;

  const GameConclusion({
    this.character,
    this.weapon,
    this.room
  });

  bool isGameOver() =>character != null && weapon != null && room != null;

  @override
  List<Object?> get props => [
    character,
    weapon,
    room
  ];
}