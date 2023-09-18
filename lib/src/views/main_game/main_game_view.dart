import 'dart:math';

import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_bloc.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_event.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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


// todo - requires player names to be unique
class MainGameViewState extends State<MainGameView> {

  late MainGameBloc _mainGameBloc;

  bool isMarkingDialogOpen = false;
  String? selectedMarkingFromDialog;

  late GameState charactersGameState;
  late GameState weaponsGameState;
  late GameState roomsGameState;

  @override
  void initState() {
    super.initState();

    _mainGameBloc = BlocProvider.of<MainGameBloc>(context);
    // todo - enforce player ordering here
    charactersGameState = MainGameStateModified.emptyCharactersGameState(widget.gameDefinition.playerNames.values.toList());
    weaponsGameState = MainGameStateModified.emptyWeaponsGameState(widget.gameDefinition.playerNames.values.toList());
    roomsGameState = MainGameStateModified.emptyRoomsGameState(widget.gameDefinition.playerNames.values.toList());



    _setupGameState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameDefinition.gameName, style: const TextStyle(color: Colors.teal),),
        iconTheme: const IconThemeData(
          color: Colors.teal,
        ),
      ),
      body: BlocListener<MainGameBloc, MainGameState>(
        listener: (context, state) {
          if (state is MainGameStateModified) {
            charactersGameState = state.charactersGameState;
            weaponsGameState = state.weaponsGameState;
            roomsGameState = state.roomsGameState;
          }
        },
        child: WillPopScope(
          onWillPop: () {
            // todo - ask for confirmation and notify user that game state will be saved
            return Future.value(true);
          },
          child: BlocBuilder<MainGameBloc, MainGameState> (
            builder: (context, state) {
              if (state is MainGameStateModified) {
                return _mainBody(state);
              }
              else {
                return WidgetUtils.progressIndicator();
              }
            },
          ),
        ),
      ),
      // floatingActionButton: dynamicActionButtons,
      // bottomNavigationBar: WidgetUtils.wrapAdWidgetWithUpgradeToMobileTextIfNeeded(adWidget, maxHeight),
    );
  }

  _setupGameState() {
    // Mark everything as unavailable for the current user
    print(roomsGameState);
    print(charactersGameState);
    print(weaponsGameState);

    ConstantUtils.allEntitites.forEach((entityName) {
      if (ConstantUtils.roomList.contains(entityName)) {
        roomsGameState[entityName]![widget.gameDefinition.playerNames[0]!] = [ConstantUtils.cross];
      }
      else if (ConstantUtils.characterList.contains(entityName)) {
        charactersGameState[entityName]![widget.gameDefinition.playerNames[0]!] = [ConstantUtils.cross];
      }
      if (ConstantUtils.weaponList.contains(entityName)) {
        weaponsGameState[entityName]![widget.gameDefinition.playerNames[0]!] = [ConstantUtils.cross];
      }
    });

    // todo - stack of operations to then UNDO
    // perhaps keep snapshots of it?
    // When a "Tick" is added, every other user is deemed to not have it
    widget.gameDefinition.initialCards.forEach((element) {
      if (ConstantUtils.roomList.contains(element.cardName())) {
        roomsGameState[element.cardName()] = {
          widget.gameDefinition.playerNames[0]!: [ConstantUtils.tick],
          ...(
              Map.fromEntries(
                  widget.gameDefinition.playerNames.entries
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
          widget.gameDefinition.playerNames[0]!: [ConstantUtils.tick],
          ...(
              Map.fromEntries(
                  widget.gameDefinition.playerNames.entries
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
          widget.gameDefinition.playerNames[0]!: [ConstantUtils.tick],
          ...(
              Map.fromEntries(
                  widget.gameDefinition.playerNames.entries
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


    _mainGameBloc.add(
        MainGameStateChanged(
          charactersGameState: charactersGameState,
          weaponsGameState: weaponsGameState,
          roomsGameState: roomsGameState,
        )
    );
  }

  _mainBody(MainGameStateModified state) {
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
                  minWidth: ScreenUtils.getScreenWidth(context) * 2/3,
                  maxWidth: (ScreenUtils.getScreenWidth(context) * 2) + (ScreenUtils.getScreenWidth(context) / 3),
                ),
                child: IntrinsicWidth(
                  child: _generateEntityMarkings(state),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _generateEntityNamesList() {
    return SizedBox(
      width: ScreenUtils.getScreenWidth(context) / 3,
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
                        currentEntity,
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
                        currentEntity,
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
                      currentEntity,
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


  noPlayersHaveThisCard(EntityType entityType, String currentEntity) {
    if (entityType == EntityType.Room) {
      return widget.gameDefinition.playerNames.entries
          .map((e) => e.value)
          .map((e) => roomsGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
    else if (entityType == EntityType.Weapon) {
      return widget.gameDefinition.playerNames.entries
          .map((e) => e.value)
          .map((e) => weaponsGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
    else {
      return widget.gameDefinition.playerNames.entries
          .map((e) => e.value)
          .map((e) => charactersGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
  }

  _generateEntityMarkings(MainGameStateModified state) {
    return SizedBox(
      width: min(
          widget.gameDefinition.totalPlayers * ScreenUtils.getScreenWidth(context) / 3,
          (ScreenUtils.getScreenWidth(context) * 2) - (ScreenUtils.getScreenWidth(context) / 3)
      ),
      child: Column(
        children: [
          _divider(),
          _playerNamesHeader(),
          _divider(),
          _generateCharactersListMarkings(state),
          _divider(),
          _playerNamesHeader(),
          _divider(),
          _generateWeaponsListMarkings(state),
          _divider(),
          _playerNamesHeader(),
          _divider(),
          _generateRoomsListMarkings(state),
          _divider(),
        ],
      ),
    );
  }

  _playerNamesHeader() {
    return SizedBox(
      height: 22.5,
      child: Row(
        // todo - arrange in order
        children: widget.gameDefinition.playerNames.values.map((e) {
          return [
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  e,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold
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

  // todo - ensure same constriants hold for columns in landscape too - so that user can see more columns in one go without scrolling
  _generateRoomsListMarkings(MainGameStateModified state) {
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
              // todo - arrange in order
              children: widget.gameDefinition.playerNames.values.map((currentPlayerName) {
                return [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        final currentMarkings = roomsGameState[currentEntity]![currentPlayerName]!;
                        // Only show dialog select if not an initial card from GameDefinition
                        if (!(currentPlayerName == widget.gameDefinition.playerNames[0]!) &&
                            !roomsGameState[currentEntity]![widget.gameDefinition.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                          _showMarkerSelectDialog(EntityType.Room, currentEntity, currentPlayerName, currentMarkings);
                        }
                      },
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInRoomCellContentsBasedOnState(currentEntity, currentPlayerName, state),
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

  _generateWeaponsListMarkings(MainGameStateModified state) {
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
              // todo - arrange in order
              children: widget.gameDefinition.playerNames.values.map((currentPlayerName) {
                return [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        final currentMarkings = weaponsGameState[currentEntity]![currentPlayerName]!;
                        if (!(currentPlayerName == widget.gameDefinition.playerNames[0]!) &&
                            !weaponsGameState[currentEntity]![widget.gameDefinition.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                          _showMarkerSelectDialog(EntityType.Weapon, currentEntity, currentPlayerName, currentMarkings);
                        }
                      },
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInWeaponCellContentsBasedOnState(currentEntity, currentPlayerName, state),
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

  _generateCharactersListMarkings(MainGameStateModified state) {
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
              // todo - arrange in order
              children: widget.gameDefinition.playerNames.values.map((currentPlayerName) {
                return [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        final currentMarkings = charactersGameState[currentCharacter]![currentPlayerName]!;
                        if (!(currentPlayerName == widget.gameDefinition.playerNames[0]!) &&
                            !charactersGameState[currentCharacter]![widget.gameDefinition.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                          _showMarkerSelectDialog(EntityType.Character, currentCharacter, currentPlayerName, currentMarkings);
                        }
                      },
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInCharacterCellContentsBasedOnState(currentCharacter, currentPlayerName, state),
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

  _fillInCharacterCellContentsBasedOnState(String currentCharacter, String playerName, MainGameStateModified state) {
    if (state.charactersGameState[currentCharacter]?[playerName]?.contains("Tick") ?? false) {
      return const Center(
        child: SizedBox(
          width: 30,
          child: CircleAvatar(
            child: Icon(Icons.check, size: 16,),
          ),
        ),
      );
    }
    if (state.charactersGameState[currentCharacter]?[playerName]?.contains("X") ?? false) {
      return const Center(
        child: SizedBox(
          width: 30,
          child: CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.close, size: 16, color: Colors.white,),
          ),
        ),
      );
    }
    if (state.charactersGameState[currentCharacter]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return Center(
        child: Wrap(
          spacing: 1.5,
          runSpacing: 1.5,
          children: (state
              .charactersGameState[currentCharacter]?[playerName] ?? [])
              .map((marking) {
            return _maybeMarker2(marking, () {
              charactersGameState[currentCharacter]![playerName] =
                  List.from(charactersGameState[currentCharacter]?[playerName] ?? [])..remove(marking);
            });
          }).toList() ,
        ),
      );
      return  GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        children: (state
            .charactersGameState[currentCharacter]?[playerName] ?? [])
            .map((marking) {
              return _maybeMarker2(marking, () {});
            }).toList(),
      );
    }
    else {
      return Center(
        child: Container(),
      );
    }
  }

  _fillInRoomCellContentsBasedOnState(String currentRoom, String playerName, MainGameStateModified state) {
    if (state.roomsGameState[currentRoom]?[playerName]?.contains("Tick") ?? false) {
      return const Center(
        child: SizedBox(
          width: 30,
          child: CircleAvatar(
            child: Icon(Icons.check, size: 16,),
          ),
        ),
      );
    }
    if (state.roomsGameState[currentRoom]?[playerName]?.contains("X") ?? false) {
      return const Center(
        child: SizedBox(
          width: 30,
          child: CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.close, size: 16, color: Colors.white,),
          ),
        ),
      );
    }
    if (state.roomsGameState[currentRoom]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return Center(
        child: Wrap(
          spacing: 2.5,
          runSpacing: 2.5,
          children: (state
              .roomsGameState[currentRoom]?[playerName] ?? [])
              .map((marking) {
            return _maybeMarker2(marking, () {
              roomsGameState[currentRoom]![playerName] =
              List.from(roomsGameState[currentRoom]?[playerName] ?? [])..remove(marking);
            });
          }).toList() ,
        ),
      );
      return  GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        children: (state
            .roomsGameState[currentRoom]?[playerName] ?? [])
            .map((marking) {
              return _maybeMarker2(marking, () {});
        }).toList(),
      );
    }
    else {
      return Center(
        child: Container(),
      );
    }
  }

  _fillInWeaponCellContentsBasedOnState(String currentWeapon, String playerName, MainGameStateModified state) {
    if (state.weaponsGameState[currentWeapon]?[playerName]?.contains("Tick") ?? false) {
      return const Center(
        child: SizedBox(
          width: 30,
          child: CircleAvatar(
            child: Icon(Icons.check, size: 16,),
          ),
        ),
      );
    }
    if (state.weaponsGameState[currentWeapon]?[playerName]?.contains("X") ?? false) {
      return const Center(
        child: SizedBox(
          width: 30,
          child: CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.close, size: 16, color: Colors.white,),
          ),
        ),
      );
    }
    if (state.weaponsGameState[currentWeapon]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return Center(
        child: Wrap(
          spacing: 2.5,
          runSpacing: 2.5,
          children: (state
              .weaponsGameState[currentWeapon]?[playerName] ?? [])
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
      color: Colors.teal,
    );
  }

  Widget _verticalDivider2() {
    return const VerticalDivider(
      width: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT / 2,
      thickness: 2.5,
      // indent: 20,
      // endIndent: 0,
      color: Colors.teal,
    );
  }

  _divider() {
    return Divider(
      height: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT.toDouble(),
      thickness: 5,
      endIndent: 0,
      color: Colors.teal,
    );
  }


  _divider2() {
    return Divider(
      height: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT.toDouble(),
      thickness: 2.5,
      endIndent: 0,
      color: Colors.teal,
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
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 18
        ),
      ),
    );
  }

  // todo - bug when numbers/letters are added afer resetting a cell?
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
          charactersGameState: charactersGameState,
          weaponsGameState: weaponsGameState,
          roomsGameState: roomsGameState,
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
              widget.gameDefinition.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
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
            widget.gameDefinition.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
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
            widget.gameDefinition.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
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
            charactersGameState: charactersGameState,
            weaponsGameState: weaponsGameState,
            roomsGameState: roomsGameState,
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
            backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
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
            backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
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
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Center(
                    child: Text(
                      "Select a marker to apply to the character/player combo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.teal
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
                        color: Colors.teal,
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
                      color: Colors.teal,
                      fontSize: 16,
                    ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  children: [
                    /**
                     * todo - need to set isSelected on the basis of cell
                     */
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
                    color: Colors.teal,
                    fontSize: 16,
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  padding: const EdgeInsets.all(5),
                  children: [
                    _maybeMarker("A", currentMarkings.contains("A"),  () {
                      _setStateAndPop("A", context);
                    }),
                    _maybeMarker("B", currentMarkings.contains("B"),  () {
                      _setStateAndPop("B", context);
                    }),
                    _maybeMarker("C", currentMarkings.contains("C"), () {
                      _setStateAndPop("C", context);
                    }),
                    _maybeMarker("D", currentMarkings.contains("D"), () {
                      _setStateAndPop("D", context);
                    }),
                    _maybeMarker("E", currentMarkings.contains("E"), () {
                      _setStateAndPop("E", context);
                    }),
                    _maybeMarker("F", currentMarkings.contains("F"), () {
                      _setStateAndPop("F", context);
                    }),
                    _maybeMarker("G", currentMarkings.contains("G"), () {
                      _setStateAndPop("G", context);
                    }),
                    _maybeMarker("H", currentMarkings.contains("H"), () {
                      _setStateAndPop("H", context);
                    }),
                    _maybeMarker("I", currentMarkings.contains("I"), () {
                      _setStateAndPop("I", context);
                    }),
                    _maybeMarker("J", currentMarkings.contains("J"),  () {
                      _setStateAndPop("J", context);
                    }),
                    _maybeMarker("K", currentMarkings.contains("K"), () {
                      _setStateAndPop("K", context);
                    }),
                    _maybeMarker("L", currentMarkings.contains("L"), () {
                      _setStateAndPop("L", context);
                    }),
                    _maybeMarker("M", currentMarkings.contains("M"), () {
                      _setStateAndPop("M", context);
                    }),
                    _maybeMarker("N", currentMarkings.contains("N"), () {
                      _setStateAndPop("N", context);
                    }),
                    _maybeMarker("O", currentMarkings.contains("O"),  () {
                      _setStateAndPop("O", context);
                    }),
                    _maybeMarker("P", currentMarkings.contains("P"), () {
                      _setStateAndPop("P", context);
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
            backgroundColor: isSelectedAlready ? Colors.redAccent : Colors.teal,
            child: Text(
                text,
                style: TextStyle(
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
      width: 15,
      height: 15,
      child: GestureDetector(
        onLongPress: onTap,
        child: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Text(
              text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}