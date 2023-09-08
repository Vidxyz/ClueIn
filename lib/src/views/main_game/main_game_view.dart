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

    // todo - stack of operations to then UNDO
    // When a "Tick" is added, every other user is deemed to not have it
    widget.gameDefinition.initialCards.forEach((element) {
      if (ConstantUtils.roomList.contains(element.cardName())) {
        roomsGameState[element.cardName()] = {
          widget.gameDefinition.playerNames[0]!: ["Tick"],
          ...(
            Map.fromEntries(
                widget.gameDefinition.playerNames.entries
                    .where((element) => element.key != 0)
                    .map((e) => e.value)
                    .map((e) {
                  return MapEntry(e, ["X"]);
                })
            )
          )
        };
      }
      else if (ConstantUtils.characterList.contains(element.cardName())) {
        charactersGameState[element.cardName()] = {
          widget.gameDefinition.playerNames[0]!: ["Tick"],
          ...(
              Map.fromEntries(
                  widget.gameDefinition.playerNames.entries
                      .where((element) => element.key != 0)
                      .map((e) => e.value)
                      .map((e) {
                    return MapEntry(e, ["X"]);
                  })
              )
          )
        };
      }
      else {
        weaponsGameState[element.cardName()] = {
          widget.gameDefinition.playerNames[0]!: ["Tick"],
          ...(
              Map.fromEntries(
                  widget.gameDefinition.playerNames.entries
                      .where((element) => element.key != 0)
                      .map((e) => e.value)
                      .map((e) {
                    return MapEntry(e, ["X"]);
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
            height: 50,
            child: Center(
              child: Card(
                child: Center(child: Text(currentEntity, textAlign: TextAlign.center)),
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
            height: 50,
            child: Center(
              child: Card(
                child: Center(child: Text(currentEntity, textAlign: TextAlign.center)),
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
            height: 50,
            child: Center(
              child: Card(
                child: Center(child: Text(currentEntity, textAlign: TextAlign.center,)),
              ),
            ),
          );
        }
    );
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
          return GestureDetector(
            onTap: () {
              print("Index $index has been tapped");
            },
            child: SizedBox(
              height: 50,
              child:  Row(
                // todo - arrange in order
                children: widget.gameDefinition.playerNames.values.map((e) {
                  return [
                    Expanded(
                      flex: 3,
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInRoomCellContentsBasedOnState(currentEntity, e, state),
                      ),
                    ),
                    _verticalDivider2()
                  ];
                }).expand((element) => element).toList(),
              ),
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
          return GestureDetector(
            onTap: () {
              print("Index $index has been tapped");
            },
            child: SizedBox(
              height: 50,
              child:  Row(
                // todo - arrange in order
                children: widget.gameDefinition.playerNames.values.map((e) {
                  return [
                    Expanded(
                      flex: 3,
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInWeaponCellContentsBasedOnState(currentEntity, e, state),
                      ),
                    ),
                    _verticalDivider2()
                  ];
                }).expand((element) => element).toList(),
              ),
            ),
          );
        }
    );
  }

  // todo - set game state here based on game data
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
          return GestureDetector(
            onTap: () {
              print("Index $index has been tapped");
            },
            child: SizedBox(
              height: 50,
              child: Row(
                // todo - arrange in order
                children: widget.gameDefinition.playerNames.values.map((playerName) {
                  return [
                    Expanded(
                      flex: 3,
                      // todo - fill this in accoridng to gamestate
                      child: Card(
                        color: Colors.grey.shade200,
                        child: _fillInCharacterCellContentsBasedOnState(currentCharacter, playerName, state),
                      ),
                    ),
                    _verticalDivider2()
                  ];
                }).expand((element) => element).toList(),
              ),
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
}