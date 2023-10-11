import 'package:cluein_app/src/models/game_card.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:equatable/equatable.dart';

class GameDefinition extends Equatable {
  final String gameId;
  final String gameName;
  final int totalPlayers;
  final Map<int, String> playerNames;
  final List<GameCard> initialCards;

  final List<GameCard> publicInfoCards;

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
  ///
  final GameState charactersGameState;
  final GameState weaponsGameState;
  final GameState roomsGameState;

  final GameBackgroundColorState cellColoursState;

  final DateTime lastSaved;

  const GameDefinition({
    required this.gameId,
    required this.gameName,
    required this.totalPlayers,
    required this.playerNames,
    required this.initialCards,
    required this.lastSaved,
    required this.publicInfoCards,
    this.charactersGameState = const {},
    this.weaponsGameState = const {},
    this.roomsGameState = const {},
    this.cellColoursState = const {},
  });

  @override
  List<Object?> get props => [
    gameId,
    gameName,
    totalPlayers,
    playerNames,
    initialCards,
    charactersGameState,
    weaponsGameState,
    roomsGameState,
    cellColoursState,
    lastSaved,
    publicInfoCards,
  ];

  factory GameDefinition.fromJson(Map<String, dynamic> json) => GameDefinitionFromJson(json);

  String toJson() => GameDefinitionToJson2(this);

  static GameDefinition GameDefinitionFromJson(Map<String, dynamic> json) {
    return GameDefinition(
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String,
      totalPlayers: json['totalPlayers'] as int,
      playerNames: (json['playerNames'] as Map<String, dynamic>).map((key, value) => MapEntry(int.parse(key), value.toString())),
      lastSaved: DateTime.parse(json['lastSaved'] as String),
      publicInfoCards: (json['publicInfoCards'] as List<dynamic>)
        .map((e) => GameCard.fromString(e.toString()))
        .toList(),
      initialCards: (json['initialCards'] as List<dynamic>)
          .map((e) => GameCard.fromString(e.toString()))
          .toList(),
      charactersGameState: (json['charactersGameState'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map((key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((e) => e.toString()).toList()
          ))
      )),
      weaponsGameState: (json['weaponsGameState'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map((key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((e) => e.toString()).toList()
          ))
      )),
      roomsGameState: (json['roomsGameState'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map((key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((e) => e.toString()).toList()
          ))
      )),
      cellColoursState: (json['cellColoursState'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map((key, value) => MapEntry(
              key,
              int.parse((value as String))
          ))
      )),
    );
  }


  static String GameDefinitionToJson2(GameDefinition instance) =>
    '''
      {
        "gameId" : "${instance.gameId}",
        "gameName" : "${instance.gameName}",
        "totalPlayers" : ${instance.totalPlayers},
        "playerNames" : {
          ${instance.playerNames.entries.map((e) {
            return '''
                  "${e.key}" : "${e.value}"
                  ''';
          }).join(",")}
        },
        "lastSaved" : "${DateTime.now().toIso8601String()}",
        "initialCards" : [
          ${instance.initialCards.map((e) => '"${e.cardName()}"').toList().join(",")}
        ],
        "publicInfoCards" : [
          ${instance.publicInfoCards.map((e) => '"${e.cardName()}"').toList().join(",")}
        ],
        "charactersGameState" : {
          ${gameStateToJson(instance.charactersGameState)}
        },
        "weaponsGameState" : {
          ${gameStateToJson(instance.weaponsGameState)}
        },
        "roomsGameState" : {
          ${gameStateToJson(instance.roomsGameState)}
        },
        "cellColoursState" : {
          ${cellColoursStateToJson(instance.cellColoursState)}
        }
      }
    ''';

  static String gameStateToJson(GameState state) {
    return state.entries.map((e) {
      return '''
        "${e.key}" : {
          ${e.value.entries.map((e2) {
            return '''
              "${e2.key}" : [
                ${e2.value.map((e3) => '"$e3"').toList().join(",")}
              ]
            ''';
          }).toList().join(", ")}
        }
      ''';
    }).join(", ");
  }

  static String cellColoursStateToJson(GameBackgroundColorState state) {
    return state.entries.map((e) {
      return '''
        "${e.key}" : {
          ${e.value.entries.map((e2) {
        return '''
              "${e2.key}" : "${e2.value}"
            ''';
      }).toList().join(", ")}
        }
      ''';
    }).join(", ");
  }

}