import 'dart:math';

import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/models/stack.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_bloc.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_event.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum EntityType { Character, Weapon, Room }

class MainGameView extends StatefulWidget {
  static const String routeName = "game";

  final GameDefinition gameDefinition;

  const MainGameView({
    super.key,
    required this.gameDefinition
  });

  static Route<bool> route({
    required GameDefinition gameDefinition,
  }) => MaterialPageRoute(
    settings: const RouteSettings(
        name: routeName
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider<MainGameBloc>(
            create: (context) => MainGameBloc()),
      ],
      child: MainGameView(
        gameDefinition: gameDefinition,
      ),
    ),
  );

  @override
  State<StatefulWidget> createState() {
    return MainGameViewState();
  }
}


class MainGameViewState extends State<MainGameView> {

  late MainGameBloc _mainGameBloc;

  bool isMarkingDialogOpen = false;
  String? selectedMarkingFromDialog;

  List<MapEntry<int, String>> playerNameMapEntries = [];

  late GameState charactersGameState;
  late GameState weaponsGameState;
  late GameState roomsGameState;

  late GameDefinition gameDefinitionState;

  late OperationStack<String> undoStack;
  late OperationStack<String> redoStack;

  String? editedNameValue;


  @override
  void initState() {
    super.initState();

    _mainGameBloc = BlocProvider.of<MainGameBloc>(context);

    gameDefinitionState = widget.gameDefinition;

    playerNameMapEntries = List.from(gameDefinitionState.playerNames.entries.toList());
    playerNameMapEntries.sort((a, b) => a.key.compareTo(b.key));

    charactersGameState = MainGameStateModified.emptyCharactersGameState(playerNameMapEntries.map((e) => e.value).toList());
    weaponsGameState = MainGameStateModified.emptyWeaponsGameState(playerNameMapEntries.map((e) => e.value).toList());
    roomsGameState = MainGameStateModified.emptyRoomsGameState(playerNameMapEntries.map((e) => e.value).toList());

    undoStack = OperationStack<String>([]);
    redoStack = OperationStack<String>([]);

    _setupGameStateInitially();
  }

  bool _canUndo() => undoStack.isNotEmpty;
  bool _canRedo() => redoStack.isNotEmpty;

  _performUndo() {
    if (_canUndo()) {
      final currentState = _mainGameBloc.state;
      if (currentState is MainGameStateModified) {
        _mainGameBloc.add(
            UndoLastMove(
                initialGame: gameDefinitionState,
                charactersGameState: charactersGameState,
                weaponsGameState: weaponsGameState,
                roomsGameState: roomsGameState,
                undoStack: undoStack,
                redoStack: redoStack
            )
        );
      }
    }
  }


  _performRedo() {
    if (_canRedo()) {
      final currentState = _mainGameBloc.state;
      if (currentState is MainGameStateModified) {
        _mainGameBloc.add(
            RedoLastMove(
                initialGame: gameDefinitionState,
                charactersGameState: charactersGameState,
                weaponsGameState: weaponsGameState,
                roomsGameState: roomsGameState,
                undoStack: undoStack,
                redoStack: redoStack
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameDefinitionState.gameName, style: const TextStyle(color: ConstantUtils.primaryAppColor),),
        iconTheme: const IconThemeData(
          color: ConstantUtils.primaryAppColor,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.undo,
              color: _canUndo() ? ConstantUtils.primaryAppColor : Colors.grey,
            ),
            onPressed: _performUndo,
          ),
          IconButton(
            icon: Icon(
              Icons.redo,
              color: _canRedo() ? ConstantUtils.primaryAppColor : Colors.grey,
            ),
            onPressed: _performRedo,
          ),
        ],
      ),
      body: BlocListener<MainGameBloc, MainGameState>(
        listener: (context, state) {
          if (state is MainGameStateModified) {
            setState(() {
              charactersGameState = state.charactersGameState;
              weaponsGameState = state.weaponsGameState;
              roomsGameState = state.roomsGameState;

              undoStack = state.undoStack;
              redoStack = state.redoStack;
            });
          }
        },
        child: _mainBody(),
      ),
    );
  }

  _setupGameStateInitially() {
    // Mark everything as unavailable for the current user
    markEverythingAsUnableForCurrentUser() {
      ConstantUtils.allEntitites.forEach((entityName) {
        if (ConstantUtils.roomList.contains(entityName)) {
          roomsGameState[entityName]![gameDefinitionState.playerNames[0]!] = [ConstantUtils.cross];
        }
        else if (ConstantUtils.characterList.contains(entityName)) {
          charactersGameState[entityName]![gameDefinitionState.playerNames[0]!] = [ConstantUtils.cross];
        }
        if (ConstantUtils.weaponList.contains(entityName)) {
          weaponsGameState[entityName]![gameDefinitionState.playerNames[0]!] = [ConstantUtils.cross];
        }
      });
    }

    setStateBasedOnInitialCards() {
      // When a "Tick" is added, every other user is deemed to not have it
      gameDefinitionState.initialCards.forEach((element) {
        if (ConstantUtils.roomList.contains(element.cardName())) {
          roomsGameState[element.cardName()] = {
            gameDefinitionState.playerNames[0]!: [ConstantUtils.tick],
            ...(
                Map.fromEntries(
                    gameDefinitionState.playerNames.entries
                        .where((element) => element.key != 0)
                        .map((e) => e.value)
                        .map((e) {
                      return MapEntry(e, [ConstantUtils.cross]);
                    })
                )
            )
          };
        }
        else if (ConstantUtils.characterList.contains(element.cardName())) {
          charactersGameState[element.cardName()] = {
            gameDefinitionState.playerNames[0]!: [ConstantUtils.tick],
            ...(
                Map.fromEntries(
                    gameDefinitionState.playerNames.entries
                        .where((element) => element.key != 0)
                        .map((e) => e.value)
                        .map((e) {
                      return MapEntry(e, [ConstantUtils.cross]);
                    })
                )
            )
          };
        }
        else {
          weaponsGameState[element.cardName()] = {
            gameDefinitionState.playerNames[0]!: [ConstantUtils.tick],
            ...(
                Map.fromEntries(
                    gameDefinitionState.playerNames.entries
                        .where((element) => element.key != 0)
                        .map((e) => e.value)
                        .map((e) {
                      return MapEntry(e, [ConstantUtils.cross]);
                    })
                )
            )
          };
        }
      });
    }


    setStateBasedOnGameDefinitionState() {
      gameDefinitionState.charactersGameState.entries.forEach((element) {
        final currentCharacter = element.key;
        element.value.entries.forEach((element2) {
          final currentPlayer = element2.key;
          final markings = element2.value;
          charactersGameState[currentCharacter]![currentPlayer] = markings;
        });
      });

      gameDefinitionState.weaponsGameState.entries.forEach((element) {
        final currentWeapon = element.key;
        element.value.entries.forEach((element2) {
          final currentPlayer = element2.key;
          final markings = element2.value;
          weaponsGameState[currentWeapon]![currentPlayer] = markings;
        });
      });
      gameDefinitionState.roomsGameState.entries.forEach((element) {
        final currentRoom = element.key;
        element.value.entries.forEach((element2) {
          final currentPlayer = element2.key;
          final markings = element2.value;
          roomsGameState[currentRoom]![currentPlayer] = markings;
        });
      });
    }


    markEverythingAsUnableForCurrentUser();
    setStateBasedOnInitialCards();
    setStateBasedOnGameDefinitionState();

    _mainGameBloc.add(
        MainGameStateLoadInitial(
          initialGame: gameDefinitionState,
          charactersGameState: charactersGameState,
          weaponsGameState: weaponsGameState,
          roomsGameState: roomsGameState,
        )
    );
  }

  _mainBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        children: [
          _generateEntityNamesList(),
        SizedBox(
          height: ((ConstantUtils.CELL_SIZE_DEFAULT * ConstantUtils.allEntitites.length ) +
              (10 * ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT)).toDouble(),
          child: _verticalDivider(),
        ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) * 2/3,
                  maxWidth: (min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) * 2) + (min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) / 3),
                ),
                child: _generateEntityMarkings(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _generateEntityNamesList() {
    return SizedBox(
      width: min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) / 3,
      child: Column(
        children: [
          _divider(),
          _heading("Characters"),
          _divider(),
          _generateCharactersList(),
          _divider(),
          _heading("Weapons"),
          _divider(),
          _generateWeaponsList(),
          _divider(),
          _heading("Rooms"),
          _divider(),
          _generateRoomList(),
          _divider(),
        ],
      ),
    );
  }

  _generateCharactersList() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 1,
            child: _divider2_5(),
          );
        },
        itemCount: ConstantUtils.characterList.length,
        itemBuilder: (context, index) {
          final currentEntity = ConstantUtils.characterList[index];
          return SizedBox(
            height: ConstantUtils.CELL_SIZE_DEFAULT.toDouble(),
            child: Center(
              child: Card(
                child: Center(
                    child: Text(
                        ConstantUtils.entityNameToDisplayNameMap[currentEntity] ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: noPlayersHaveThisCard(EntityType.Character, currentEntity) ? Colors.red : null
                        ),
                    )
                ),
              ),
            ),
          );
        }
    );
  }

  _generateWeaponsList() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 1,
            child: _divider2_5(),
          );
        },
        itemCount: ConstantUtils.weaponList.length,
        itemBuilder: (context, index) {
          final currentEntity = ConstantUtils.weaponList[index];
          return SizedBox(
            height: ConstantUtils.CELL_SIZE_DEFAULT.toDouble(),
            child: Center(
              child: Card(
                child: Center(
                    child: Text(
                        ConstantUtils.entityNameToDisplayNameMap[currentEntity] ?? "",
                        textAlign: TextAlign.center,
                      style: TextStyle(
                          color: noPlayersHaveThisCard(EntityType.Weapon, currentEntity) ? Colors.red : null
                      ),
                    )
                ),
              ),
            ),
          );
        }
    );
  }

  _generateRoomList() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 1,
            child: _divider2_5(),
          );
        },
        itemCount: ConstantUtils.roomList.length,
        itemBuilder: (context, index) {
          final currentEntity = ConstantUtils.roomList[index];
          return SizedBox(
            height: ConstantUtils.CELL_SIZE_DEFAULT.toDouble(),
            child: Center(
              child: Card(
                child: Center(
                    child: Text(
                      ConstantUtils.entityNameToDisplayNameMap[currentEntity] ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: noPlayersHaveThisCard(EntityType.Room, currentEntity) ? Colors.red : null
                      ),
                    )
                ),
              ),
            ),
          );
        }
    );
  }


  bool noPlayersHaveThisCard(EntityType entityType, String currentEntity) {
    if (entityType == EntityType.Room) {
      return gameDefinitionState.playerNames.entries
          .map((e) => e.value)
          .map((e) => roomsGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
    else if (entityType == EntityType.Weapon) {
      return gameDefinitionState.playerNames.entries
          .map((e) => e.value)
          .map((e) => weaponsGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
    else {
      return gameDefinitionState.playerNames.entries
          .map((e) => e.value)
          .map((e) => charactersGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
  }

  _generateEntityMarkings() {
    return SizedBox(
      width: max(
          (gameDefinitionState.totalPlayers * ConstantUtils.CELL_SIZE_HORIZONTAL_DEFAULT).toDouble(),
          ScreenUtils.getScreenWidth(context) - (min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) / 3)
      ),
      child: Column(
        children: [
          _divider(),
          _playerNamesHeader(),
          _divider(),
          _generateCharactersListMarkings(),
          _divider(),
          _playerNamesHeader(),
          _divider(),
          _generateWeaponsListMarkings(),
          _divider(),
          _playerNamesHeader(),
          _divider(),
          _generateRoomsListMarkings(),
          _divider(),
        ],
      ),
    );
  }

  _showEditPlayerNameDialog(String currentPlayerName) {
    _dismissDialogButton() {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(ConstantUtils.primaryAppColor),
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
          child: const Text("Go back", style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      );
    }

    final currentPlayerNameId = currentPlayerName.split(ConstantUtils.UNIQUE_NAME_DELIMITER).lastOrNull ?? "";
    showDialog(context: context, builder: (context) {
      return Dialog(
          child: SizedBox(
            height: ScreenUtils.getScreenHeight(context) / 3,
            child: Scaffold(
                bottomNavigationBar: Row(
                  children: [
                    Expanded(
                      child: _dismissDialogButton(),
                    ),
                  ],
                ),
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text("Edit player name", style: TextStyle(color: ConstantUtils.primaryAppColor),),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                      ],
                      onChanged: (text) {
                        editedNameValue = text.trim();
                      },
                      initialValue: currentPlayerName.split(ConstantUtils.UNIQUE_NAME_DELIMITER).firstOrNull ?? "",
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        // hintText: playerNamesHint[index],
                        // hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ConstantUtils.primaryAppColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
          )
      );
    }).then((value) {
      if (editedNameValue != null) {
        _updatePlayerName(editedNameValue!, currentPlayerName, currentPlayerNameId);
      }
    });
  }

  _updatePlayerName(String newValue, String originalPlayerNamePlusId, currentPlayerNameId) {
    setState(() {
      // Update game definition, and update each game state
      String newPlayerNamePlusId = "${newValue}${ConstantUtils.UNIQUE_NAME_DELIMITER}${currentPlayerNameId}";
      ConstantUtils.characterList.forEach((currentCharacter) {
        final currentMarkingMap = charactersGameState[currentCharacter]!;
        currentMarkingMap[newPlayerNamePlusId] = charactersGameState[currentCharacter]![originalPlayerNamePlusId]!;
        currentMarkingMap.remove(originalPlayerNamePlusId);
        charactersGameState[currentCharacter] = currentMarkingMap;
      });
      ConstantUtils.weaponList.forEach((currentWeapon) {
        final currentMarkingMap = weaponsGameState[currentWeapon]!;
        currentMarkingMap[newPlayerNamePlusId] = weaponsGameState[currentWeapon]![originalPlayerNamePlusId]!;
        currentMarkingMap.remove(originalPlayerNamePlusId);
        weaponsGameState[currentWeapon] = currentMarkingMap;
      });
      ConstantUtils.roomList.forEach((currentRoom) {
        final currentMarkingMap = roomsGameState[currentRoom]!;
        currentMarkingMap[newPlayerNamePlusId] = roomsGameState[currentRoom]![originalPlayerNamePlusId]!;
        currentMarkingMap.remove(originalPlayerNamePlusId);
        roomsGameState[currentRoom] = currentMarkingMap;
      });

      final indexOfUpdatedPlayerName =
          gameDefinitionState.playerNames.entries.where((element) => element.value == originalPlayerNamePlusId).firstOrNull?.key ?? 0;

      final newMap = gameDefinitionState.playerNames;
      newMap[indexOfUpdatedPlayerName] = newPlayerNamePlusId;

      playerNameMapEntries = newMap.entries.toList();

      gameDefinitionState = GameDefinition(
          gameId: gameDefinitionState.gameId,
          gameName: gameDefinitionState.gameName,
          totalPlayers: gameDefinitionState.totalPlayers,
          playerNames: newMap,
          initialCards: gameDefinitionState.initialCards,
          lastSaved: gameDefinitionState.lastSaved
      );
    });

    _mainGameBloc.add(
        MainGameStateChanged(
          initialGame: gameDefinitionState,
          charactersGameState: charactersGameState,
          weaponsGameState: weaponsGameState,
          roomsGameState: roomsGameState,
          undoStack: undoStack,
          redoStack: redoStack,
        )
    );

  }

  _playerNamesHeader() {
    return SizedBox(
      height: 22.5,
      child: Row(
        children: playerNameMapEntries.map((e) => e.value).map((currentPlayerName) {
          return [
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  _showEditPlayerNameDialog(currentPlayerName);
                },
                child: Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Text(
                      currentPlayerName.split(ConstantUtils.UNIQUE_NAME_DELIMITER).firstOrNull ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _verticalDivider2()
          ];
        }).expand((element) => element).toList(),
      ),
    );
  }

  _generateRoomsListMarkings() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 1,
            child: _divider2(),
          );
        },
        itemCount: ConstantUtils.roomList.length,
        itemBuilder: (context, index) {
          final currentEntity = ConstantUtils.roomList[index];
          return SizedBox(
            height: ConstantUtils.CELL_SIZE_DEFAULT.toDouble(),
            child:  Row(
              children: playerNameMapEntries.map((e) => e.value).map((currentPlayerName) {
                return [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        final currentMarkings = roomsGameState[currentEntity]![currentPlayerName]!;
                        // Only show dialog select if not an initial card from GameDefinition
                        if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                            !roomsGameState[currentEntity]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                          _showMarkerSelectDialog(EntityType.Room, currentEntity, currentPlayerName, currentMarkings);
                        }
                      },
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInRoomCellContentsBasedOnState(currentEntity, currentPlayerName),
                      ),
                    ),
                  ),
                  _verticalDivider2()
                ];
              }).expand((element) => element).toList(),
            ),
          );
        }
    );
  }

  _generateWeaponsListMarkings() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 1,
            child: _divider2(),
          );
        },
        itemCount: ConstantUtils.weaponList.length,
        itemBuilder: (context, index) {
          final currentEntity = ConstantUtils.weaponList[index];
          return SizedBox(
            height: ConstantUtils.CELL_SIZE_DEFAULT.toDouble(),
            child:  Row(
              children: playerNameMapEntries.map((e) => e.value).map((currentPlayerName) {
                return [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        final currentMarkings = weaponsGameState[currentEntity]![currentPlayerName]!;
                        if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                            !weaponsGameState[currentEntity]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                          _showMarkerSelectDialog(EntityType.Weapon, currentEntity, currentPlayerName, currentMarkings);
                        }
                      },
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInWeaponCellContentsBasedOnState(currentEntity, currentPlayerName),
                      ),
                    ),
                  ),
                  _verticalDivider2()
                ];
              }).expand((element) => element).toList(),
            ),
          );
        }
    );
  }

  _generateCharactersListMarkings() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: ConstantUtils.characterList.length,
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 1,
            child: _divider2(),
          );
        },
        itemBuilder: (context, index) {
          final currentCharacter = ConstantUtils.characterList[index];
          return SizedBox(
            height: ConstantUtils.CELL_SIZE_DEFAULT.toDouble(),
            child: Row(
              children: playerNameMapEntries.map((e) => e.value).map((currentPlayerName) {
                return [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        final currentMarkings = charactersGameState[currentCharacter]![currentPlayerName]!;
                        if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                            !charactersGameState[currentCharacter]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                          _showMarkerSelectDialog(EntityType.Character, currentCharacter, currentPlayerName, currentMarkings);
                        }
                      },
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInCharacterCellContentsBasedOnState(currentCharacter, currentPlayerName),
                      ),
                    ),
                  ),
                  _verticalDivider2()
                ];
              }).expand((element) => element).toList(),
            ),
          );
        }
    );
  }

  _fillInCharacterCellContentsBasedOnState(String currentCharacter, String playerName) {
    if (charactersGameState[currentCharacter]?[playerName]?.contains("Tick") ?? false) {
      return Center(
        child: SizedBox(
          width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
          child: const CircleAvatar(
            child: Icon(Icons.check, size: 16,),
          ),
        ),
      );
    }
    if (charactersGameState[currentCharacter]?[playerName]?.contains("X") ?? false) {
      return Center(
        child: SizedBox(
          width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
          child: const CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.close, size: 16, color: Colors.white,),
          ),
        ),
      );
    }
    if (charactersGameState[currentCharacter]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return Center(
        child: Wrap(
          spacing: 1.5,
          runSpacing: 1.5,
          children: (
              charactersGameState[currentCharacter]?[playerName] ?? [])
              .map((marking) {
            return _maybeMarker2(marking, () {
              charactersGameState[currentCharacter]![playerName] =
                  List.from(charactersGameState[currentCharacter]?[playerName] ?? [])..remove(marking);
            });
          }).toList() ,
        ),
      );
    }
    else {
      return Center(
        child: Container(),
      );
    }
  }

  _fillInRoomCellContentsBasedOnState(String currentRoom, String playerName) {
    if (roomsGameState[currentRoom]?[playerName]?.contains("Tick") ?? false) {
      return Center(
        child: SizedBox(
          width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
          child: const CircleAvatar(
            child: Icon(Icons.check, size: 16,),
          ),
        ),
      );
    }
    if (roomsGameState[currentRoom]?[playerName]?.contains("X") ?? false) {
      return Center(
        child: SizedBox(
          width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
          child: const CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.close, size: 16, color: Colors.white,),
          ),
        ),
      );
    }
    if (roomsGameState[currentRoom]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return Center(
        child: Wrap(
          spacing: 2.5,
          runSpacing: 2.5,
          children: (
              roomsGameState[currentRoom]?[playerName] ?? [])
              .map((marking) {
            return _maybeMarker2(marking, () {
              roomsGameState[currentRoom]![playerName] =
              List.from(roomsGameState[currentRoom]?[playerName] ?? [])..remove(marking);
            });
          }).toList() ,
        ),
      );
    }
    else {
      return Center(
        child: Container(),
      );
    }
  }

  _fillInWeaponCellContentsBasedOnState(String currentWeapon, String playerName) {
    if (weaponsGameState[currentWeapon]?[playerName]?.contains("Tick") ?? false) {
      return Center(
        child: SizedBox(
          width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
          child: const CircleAvatar(
            child: Icon(Icons.check, size: 16,),
          ),
        ),
      );
    }
    if (weaponsGameState[currentWeapon]?[playerName]?.contains("X") ?? false) {
      return Center(
        child: SizedBox(
          width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
          child: const CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.close, size: 16, color: Colors.white,),
          ),
        ),
      );
    }
    if (weaponsGameState[currentWeapon]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return Center(
        child: Wrap(
          spacing: 2.5,
          runSpacing: 2.5,
          children: (weaponsGameState[currentWeapon]?[playerName] ?? [])
              .map((marking) {
            return _maybeMarker2(marking, () {
              weaponsGameState[currentWeapon]![playerName] =
              List.from(weaponsGameState[currentWeapon]?[playerName] ?? [])..remove(marking);
            });
          }).toList() ,
        ),
      );
    }
    else {
      return Center(
        child: Container(),
      );
    }
  }

  Widget _verticalDivider() {
    return const VerticalDivider(
      width: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT / 2,
      thickness: 5,
      // indent: 20,
      // endIndent: 0,
      color: ConstantUtils.primaryAppColor,
    );
  }

  Widget _verticalDivider2() {
    return const VerticalDivider(
      width: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT / 2,
      thickness: 2.5,
      // indent: 20,
      // endIndent: 0,
      color: ConstantUtils.primaryAppColor,
    );
  }

  _divider() {
    return Divider(
      height: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT.toDouble(),
      thickness: 5,
      endIndent: 0,
      color: ConstantUtils.primaryAppColor,
    );
  }


  _divider2() {
    return Divider(
      height: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT.toDouble(),
      thickness: 2.5,
      endIndent: 0,
      color: ConstantUtils.primaryAppColor,
    );
  }

  _divider2_5() {
    return Divider(
      height: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT.toDouble(),
      thickness: 2.5,
      endIndent: 0,
      color: Colors.transparent,
    );
  }

  _heading(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
            color: ConstantUtils.primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 18
        ),
      ),
    );
  }

  _markDialogAsClosedAndResetMarking(EntityType entityType, String currentEntity, String currentPlayerName) {
    if (entityType == EntityType.Character) {
      charactersGameState[currentEntity]?[currentPlayerName] = [];
    }
    else if (entityType == EntityType.Weapon) {
      weaponsGameState[currentEntity]?[currentPlayerName] = [];
    }
    else {
      roomsGameState[currentEntity]?[currentPlayerName] = [];
    }

    _mainGameBloc.add(
        MainGameStateChanged(
          initialGame: gameDefinitionState,
          charactersGameState: charactersGameState,
          weaponsGameState: weaponsGameState,
          roomsGameState: roomsGameState,
          undoStack: undoStack,
          redoStack: redoStack,
        )
    );
    setState(() {
      isMarkingDialogOpen = false;
      selectedMarkingFromDialog = null;
    });
  }

  _markDialogAsClosedAndSaveMarking(EntityType entityType, String currentEntity, String currentPlayerName) {
    if (selectedMarkingFromDialog != null) {
      // Something was selected, persist it
      if (entityType == EntityType.Character) {
        if (selectedMarkingFromDialog == ConstantUtils.tick || selectedMarkingFromDialog == ConstantUtils.cross) {
          charactersGameState[currentEntity]?[currentPlayerName] = [selectedMarkingFromDialog!];

          // If it is a tick, then others all get a cross as only one person can own a card at a time
          if (selectedMarkingFromDialog == ConstantUtils.tick) {
            final allPlayersExceptCurrent =
              gameDefinitionState.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
            allPlayersExceptCurrent.forEach((element) {
              charactersGameState[currentEntity]?[element] = [ConstantUtils.cross];
            });

          }
        }
        else {
          charactersGameState[currentEntity]?[currentPlayerName]?.remove(ConstantUtils.tick);
          charactersGameState[currentEntity]?[currentPlayerName]?.remove(ConstantUtils.cross);
          if (charactersGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            charactersGameState[currentEntity]?[currentPlayerName]?.remove(selectedMarkingFromDialog);
          }
          else {
            if ((charactersGameState[currentEntity]?[currentPlayerName]?.length ?? 0) >= ConstantUtils.MAX_MARKINGS) {
              charactersGameState[currentEntity]?[currentPlayerName]?.removeAt(0);
            }
            charactersGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog!);
          }
        }
      }
      else if (entityType == EntityType.Weapon) {
        weaponsGameState[currentEntity]?[currentPlayerName]?.remove(ConstantUtils.tick);
        weaponsGameState[currentEntity]?[currentPlayerName]?.remove(ConstantUtils.cross);
        if (selectedMarkingFromDialog == ConstantUtils.tick || selectedMarkingFromDialog == ConstantUtils.cross) {
          weaponsGameState[currentEntity]?[currentPlayerName] = [selectedMarkingFromDialog!];

          // If it is a tick, then others all get a cross as only one person can own a card at a time
          if (selectedMarkingFromDialog == ConstantUtils.tick) {
            final allPlayersExceptCurrent =
            gameDefinitionState.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
            allPlayersExceptCurrent.forEach((element) {
              weaponsGameState[currentEntity]?[element] = [ConstantUtils.cross];
            });

          }
        }
        else {
          if (weaponsGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            weaponsGameState[currentEntity]?[currentPlayerName]?.remove(selectedMarkingFromDialog);
          }
          else {
            if ((weaponsGameState[currentEntity]?[currentPlayerName]?.length ?? 0) >= ConstantUtils.MAX_MARKINGS) {
              weaponsGameState[currentEntity]?[currentPlayerName]?.removeAt(0);
            }
            weaponsGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog!);
          }
        }
      }
      else {
        roomsGameState[currentEntity]?[currentPlayerName]?.remove(ConstantUtils.tick);
        roomsGameState[currentEntity]?[currentPlayerName]?.remove(ConstantUtils.cross);
        if (selectedMarkingFromDialog == ConstantUtils.tick || selectedMarkingFromDialog == ConstantUtils.cross) {
          roomsGameState[currentEntity]?[currentPlayerName] = [selectedMarkingFromDialog!];

          // If it is a tick, then others all get a cross as only one person can own a card at a time
          if (selectedMarkingFromDialog == ConstantUtils.tick) {
            final allPlayersExceptCurrent =
            gameDefinitionState.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
            allPlayersExceptCurrent.forEach((element) {
              roomsGameState[currentEntity]?[element] = [ConstantUtils.cross];
            });

          }
        }
        else {
          if (roomsGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            roomsGameState[currentEntity]?[currentPlayerName]?.remove(selectedMarkingFromDialog);
          }
          else {
            if ((roomsGameState[currentEntity]?[currentPlayerName]?.length ?? 0) >= ConstantUtils.MAX_MARKINGS) {
              roomsGameState[currentEntity]?[currentPlayerName]?.removeAt(0);
            }
            roomsGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog!);
          }
        }
      }

      _mainGameBloc.add(
          MainGameStateChanged(
            initialGame: gameDefinitionState,
            charactersGameState: charactersGameState,
            weaponsGameState: weaponsGameState,
            roomsGameState: roomsGameState,
            undoStack: undoStack,
            redoStack: redoStack,
          )
      );
      setState(() {
        isMarkingDialogOpen = false;
        selectedMarkingFromDialog = null;
      });
    }
  }

  _showMarkerSelectDialog(
      EntityType entityType,
      String currentEntity,
      String currentPlayerName,
      List<String> currentMarkings
      ) {
    setState(() {
      isMarkingDialogOpen = true;
    });

    _resetCellButton() {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(ConstantUtils.primaryAppColor),
          ),
          onPressed: () async {
            _markDialogAsClosedAndResetMarking(entityType, currentEntity, currentPlayerName);
            Navigator.pop(context);
          },
          child: const Text("Reset cell", style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      );
    }

    _dismissDialogButton() {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(ConstantUtils.primaryAppColor),
          ),
          onPressed: () async {
            _markDialogAsClosedAndSaveMarking(entityType, currentEntity, currentPlayerName);
            Navigator.pop(context);
          },
          child: const Text("Go back", style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      );
    }

    showDialog(context: context, builder: (context) {
      return Dialog(
        child:  Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: Text(
                      "Select a marker to apply to the ${entityType.name}/Player combo",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: ConstantUtils.primaryAppColor
                      ),
                    ),
                  ),
                ),
                WidgetUtils.spacer(2.5),
                _divider(),
                const Text(
                    "For sure",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ConstantUtils.primaryAppColor,
                        fontSize: 16,
                    ),
                ),
                Row(
                  children: [
                    Expanded(
                        // Check marker
                        child: SizedBox(
                          width: 50,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMarkingFromDialog = ConstantUtils.tick;
                              });
                              Navigator.pop(context);
                            },
                            child: const CircleAvatar(
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                    ),
                    Expanded(
                      // Cross marker
                        child: SizedBox(
                          width: 50,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMarkingFromDialog = ConstantUtils.cross;
                              });
                              Navigator.pop(context);
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.close, size: 16, color: Colors.white,),
                            ),
                          ),
                        )
                    ),
                  ],
                ),
                WidgetUtils.spacer(2.5),
                _divider(),
                const Text(
                    "Numbers",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ConstantUtils.primaryAppColor,
                      fontSize: 16,
                    ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: ScreenUtils.isPortraitOrientation(context) ? 4 : 8,
                  children: [
                    _maybeMarker("1", currentMarkings.contains("1"), () {
                      _setStateAndPop("1", context);
                    }),
                    _maybeMarker("2", currentMarkings.contains("2"), () {
                      _setStateAndPop("2", context);
                    }),
                    _maybeMarker("3", currentMarkings.contains("3"),  () {
                      _setStateAndPop("3", context);
                    }),
                    _maybeMarker("4", currentMarkings.contains("4"), () {
                      _setStateAndPop("4", context);
                    }),
                    _maybeMarker("5", currentMarkings.contains("5"),  () {
                      _setStateAndPop("5", context);
                    }),
                    _maybeMarker("6", currentMarkings.contains("6"),  () {
                      _setStateAndPop("6", context);
                    }),
                    _maybeMarker("7", currentMarkings.contains("7"),  () {
                      _setStateAndPop("7", context);
                    }),
                    _maybeMarker("8", currentMarkings.contains("8"),  () {
                      _setStateAndPop("8", context);
                    }),
                    _maybeMarker("9", currentMarkings.contains("9"),  () {
                      _setStateAndPop("9", context);
                    }),
                    _maybeMarker("10", currentMarkings.contains("10"),  () {
                      _setStateAndPop("10", context);
                    }),
                    _maybeMarker("11", currentMarkings.contains("11"),  () {
                      _setStateAndPop("11", context);
                    }),
                    _maybeMarker("12", currentMarkings.contains("12"),  () {
                      _setStateAndPop("12", context);
                    }),
                    _maybeMarker("13", currentMarkings.contains("13"),  () {
                      _setStateAndPop("13", context);
                    }),
                    _maybeMarker("14", currentMarkings.contains("14"),  () {
                      _setStateAndPop("14", context);
                    }),
                    _maybeMarker("15", currentMarkings.contains("15"),  () {
                      _setStateAndPop("15", context);
                    }),
                    _maybeMarker("16", currentMarkings.contains("16"),  () {
                      _setStateAndPop("16", context);
                    }),
                  ],
                ),
                WidgetUtils.spacer(2.5),
                _divider(),
                const Text(
                  "Letters",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ConstantUtils.primaryAppColor,
                    fontSize: 16,
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: ScreenUtils.isPortraitOrientation(context) ? 4 : 8,
                  children: [
                    _maybeMarker("1", currentMarkings.contains("1"), () {
                      _setStateAndPop("1", context);
                    }),
                    _maybeMarker("2", currentMarkings.contains("2"), () {
                      _setStateAndPop("2", context);
                    }),
                    _maybeMarker("3", currentMarkings.contains("3"),  () {
                      _setStateAndPop("3", context);
                    }),
                    _maybeMarker("4", currentMarkings.contains("4"), () {
                      _setStateAndPop("4", context);
                    }),
                    _maybeMarker("5", currentMarkings.contains("5"),  () {
                      _setStateAndPop("5", context);
                    }),
                    _maybeMarker("6", currentMarkings.contains("6"),  () {
                      _setStateAndPop("6", context);
                    }),
                    _maybeMarker("7", currentMarkings.contains("7"),  () {
                      _setStateAndPop("7", context);
                    }),
                    _maybeMarker("8", currentMarkings.contains("8"),  () {
                      _setStateAndPop("8", context);
                    }),
                    _maybeMarker("9", currentMarkings.contains("9"),  () {
                      _setStateAndPop("9", context);
                    }),
                    _maybeMarker("10", currentMarkings.contains("10"),  () {
                      _setStateAndPop("10", context);
                    }),
                    _maybeMarker("11", currentMarkings.contains("11"),  () {
                      _setStateAndPop("11", context);
                    }),
                    _maybeMarker("12", currentMarkings.contains("12"),  () {
                      _setStateAndPop("12", context);
                    }),
                    _maybeMarker("13", currentMarkings.contains("13"),  () {
                      _setStateAndPop("13", context);
                    }),
                    _maybeMarker("14", currentMarkings.contains("14"),  () {
                      _setStateAndPop("14", context);
                    }),
                    _maybeMarker("15", currentMarkings.contains("15"),  () {
                      _setStateAndPop("15", context);
                    }),
                    _maybeMarker("16", currentMarkings.contains("16"),  () {
                      _setStateAndPop("16", context);
                    }),
                  ],
                ),
                WidgetUtils.spacer(2.5),
                _divider(),
              ],
            ),
          ),
          bottomNavigationBar: Row(
            children: [
              Expanded(
                child: _dismissDialogButton(),
              ),
              Expanded(
                child: _resetCellButton(),
              ),
            ],
          ),
        ),
      );
    }).then((value) => _markDialogAsClosedAndSaveMarking(entityType, currentEntity, currentPlayerName));
  }

  _setStateAndPop(String text, BuildContext context) {
    setState(() {
      selectedMarkingFromDialog = text;
      roomsGameState = roomsGameState;
      charactersGameState = charactersGameState;
      weaponsGameState = weaponsGameState;
    });
    Navigator.pop(context);
  }

  Widget _maybeMarker(String text, bool isSelectedAlready, VoidCallback onTap) {
    return SizedBox(
      width: 30,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: isSelectedAlready ? Colors.redAccent : ConstantUtils.primaryAppColor,
            child: Text(
                text,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white
                )
            ),
          ),
        ),
      ),
    );
  }

  Widget _maybeMarker2(String text, VoidCallback onTap) {
    return SizedBox(
      width: ConstantUtils.MARKING_DIAMETER,
      height: ConstantUtils.MARKING_DIAMETER,
      child: GestureDetector(
        onLongPress: onTap,
        child: CircleAvatar(
          backgroundColor: ConstantUtils.primaryAppColor,
          child: Text(
              text,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}