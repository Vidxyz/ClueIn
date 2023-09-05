import 'package:cluein_app/src/models/game_card.dart';
import 'package:equatable/equatable.dart';

class GameDefinition extends Equatable {
  final String gameId;
  final String gameName;
  final int totalPlayers;
  final Map<int, String> playerNames;
  final List<GameCard> initialCards;

  /// GameState stored on a per card basis
  /// Each card has a map associated with it
  /// Each map element is a key-value pair of playerNames -> List of string markers
  /// For example, a map could be
  /// {
  ///    "Peacock" : {
  ///     "Player1Name": ["1", "2", "X"],
  ///     "Player2Name": ["?"],
  ///     "Player3Name": ["3"],
  ///    },
  ///    "Scarlett" : {
  ///     "Player1Name": ["X"],
  ///     "Player2Name": ["?"],
  ///     "Player3Name": ["3"],
  ///    }
  ///    ...
  /// }
  final Map<String, Map<String, List<String>>> gameState;

  const GameDefinition({
    required this.gameId,
    required this.gameName,
    required this.totalPlayers,
    required this.playerNames,
    required this.initialCards,
    this.gameState = const {},
  });

  @override
  List<Object?> get props => [
    gameId,
    gameName,
    totalPlayers,
    playerNames,
    initialCards,
    gameState,
  ];

  factory GameDefinition.fromJson(Map<String, dynamic> json) => GameDefinitionFromJson(json);

  Map<String, dynamic> toJson() => GameDefinitionToJson(this);

  static GameDefinition GameDefinitionFromJson(Map<String, dynamic> json) =>
      GameDefinition(
        gameId: json['gameId'] as String,
        gameName: json['gameName'] as String,
        totalPlayers: json['totalPlayers'] as int,
        playerNames: (json['playerNames'] as Map<int, String>),
        initialCards: (json['initialCards'] as List<String>)
            .map((e) => GameCard.fromString(e))
            .toList(),
        gameState: (json['gameState'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(
                    key,
                    (value as Map<String, List<dynamic>>).map((key, value) => MapEntry(
                        key,
                        value.map((e) => e.toString()).toList()
                    ))
        )),
      );


  static Map<String, dynamic> GameDefinitionToJson(GameDefinition instance) =>
      <String, dynamic>{
        'gameId': instance.gameId,
        'gameName': instance.gameName,
        'totalPlayers': instance.totalPlayers,
        'playerNames': instance.playerNames,
        'initialCards': instance.initialCards.map((e) => e.cardName()),
        'gameState': instance.gameState,
      };

}