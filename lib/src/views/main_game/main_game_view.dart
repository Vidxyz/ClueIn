import 'dart:math';

import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/models/stack.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/keyboard_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/snackbar_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_bloc.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_event.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:cluein_app/src/views/shared_components/ads/custom_markings_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

GlobalKey cell1Key = GlobalKey();
GlobalKey cell2Key = GlobalKey();
GlobalKey undoKey = GlobalKey();
GlobalKey redoKey = GlobalKey();
GlobalKey gameNameTextKey = GlobalKey();

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
            create: (context) => MainGameBloc(
                sharedPrefs: RepositoryProvider.of<SharedPrefsRepository>(context),
            )),
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
  bool isBackgroundColourDialogOpen = false;
  bool isInferenceConfirmationDialogOpen = false;

  String? selectedMarkingFromDialog;
  Color? selectedBackgroundColourFromDialog;

  List<MapEntry<int, String>> playerNameMapEntries = [];

  late GameState charactersGameState;
  late GameState weaponsGameState;
  late GameState roomsGameState;

  late GameBackgroundColorState cellBackgroundColourState;

  late GameDefinition gameDefinitionState;

  late OperationStack<String> undoStack;
  late OperationStack<String> redoStack;

  String? editedPlayerNameValue;
  String? editedGameNameValue;

  bool hasTutorialBeenShown = false;
  List<TargetFocus> basicTargets = [];
  TutorialCoachMark? basicTutorialCoachMark;


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

    cellBackgroundColourState = MainGameStateModified.emptyCellBackgroundGameState(playerNameMapEntries.map((e) => e.value).toList());

    undoStack = OperationStack<String>([]);
    redoStack = OperationStack<String>([]);

    initTutorial();
    _setupGameStateInitially();
  }

  initTutorial() {

    // Intro screen
    basicTargets.add(
      TargetFocus(
        identify: "gameNameTextKey",
        keyTarget: gameNameTextKey,
        alignSkip: Alignment.topRight,
        color: ConstantUtils.primaryAppColor,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        enableTargetTab: true,
        paddingFocus: 0,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: WidgetUtils.skipNulls([
                  WidgetUtils.spacer(25),
                  const Align(
                    child: Text(
                      "Note observations and infer conclusions",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Assume there are 2 players, A and B. Assume A makes the following accusation",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(10),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "\"I accuse Col. Mustard of killing Ms Plum in the Kitchen with the Dagger\"",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(10),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "When B shows a card, create markings to allow for inferences later",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(10),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "For instance, add the marker \"1\" next to \"Mustard\", \"Kitchen\" and \"Dagger\"",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(10),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "If there are multiple markings over different rounds on the same card, that is evidence in favour of the respective player possessing said card.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );

    // todo - try sembast again, post MVP settings - primary colour - clue version,
    // todo - pretty up character names like rooms (col, Mr, Ms, etc) - same for confirm inference dialgos
    // todo - fix about page after that
    basicTargets.add(
      TargetFocus(
        identify: "cell1Key",
        keyTarget: cell1Key,
        alignSkip: Alignment.topRight,
        color: ConstantUtils.primaryAppColor,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        enableTargetTab: true,
        paddingFocus: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: WidgetUtils.skipNulls([
                  const Align(
                    child: Text(
                      "Tap on a cell to add or remove markings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "When a player shows a card, add a marking next to each of the possible cards it might be",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(10),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "When cards accumulate multiple distinct markings, you can infer conclusions",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(10),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Tap on a marking to remove it if needed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );

    // Long press
    basicTargets.add(
      TargetFocus(
        identify: "cell2Key",
        keyTarget: cell2Key,
        alignSkip: Alignment.topRight,
        color: ConstantUtils.primaryAppColor,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        enableTargetTab: true,
        paddingFocus: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: WidgetUtils.skipNulls([
                  const Align(
                    child: Text(
                      "Long press on a cell to change background colour",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "When you show a card someone, change the background colour to indicate what you have disclosed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(10),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Ensure you only disclose as little information as required!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );

    // Undo button
    basicTargets.add(
      TargetFocus(
        identify: "undoKey",
        keyTarget: undoKey,
        alignSkip: Alignment.topRight,
        color: ConstantUtils.primaryAppColor,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        enableTargetTab: true,
        paddingFocus: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: WidgetUtils.skipNulls([
                  WidgetUtils.spacer(25),
                  const Align(
                    child: Text(
                      "Press this button to undo your last move",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );


    // Redo button
    basicTargets.add(
      TargetFocus(
        identify: "redoKey",
        keyTarget: redoKey,
        alignSkip: Alignment.topRight,
        color: ConstantUtils.primaryAppColor,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        enableTargetTab: true,
        paddingFocus: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: WidgetUtils.skipNulls([
                  WidgetUtils.spacer(25),
                  const Align(
                    child: Text(
                      "Press this button to redo your last move",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );




    basicTutorialCoachMark = TutorialCoachMark(
      targets: basicTargets,
      colorShadow: ConstantUtils.primaryAppColor,
      hideSkip: false,
      showSkipInLastTarget: true,
      alignSkip: Alignment.topRight,
      focusAnimationDuration: const Duration(milliseconds: 200),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {},
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {},
    );
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
                redoStack: redoStack,
                cellColoursState: cellBackgroundColourState,
            )
        );
      }
    }
  }

  _performTutorial() {
    basicTutorialCoachMark?.show(context: context);
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
                redoStack: redoStack,
                cellColoursState: cellBackgroundColourState,
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            _showEditGameNameDialog();
          },
          child: Text(
            gameDefinitionState.gameName,
            key: gameNameTextKey,
            style: const TextStyle(color: ConstantUtils.primaryAppColor),
          )
        ),
        iconTheme: const IconThemeData(
          color: ConstantUtils.primaryAppColor,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help,
              color: ConstantUtils.primaryAppColor,
            ),
            onPressed: _performTutorial,
          ),
          IconButton(
            key: undoKey,
            icon: Icon(
              Icons.undo,
              color: _canUndo() ? ConstantUtils.primaryAppColor : Colors.grey,
            ),
            onPressed: _performUndo,
          ),
          IconButton(
            key: redoKey,
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

              cellBackgroundColourState = state.cellColoursState;

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

    cellBackgroundColourState = gameDefinitionState.cellColoursState;

    _mainGameBloc.add(
        MainGameStateLoadInitial(
          initialGame: gameDefinitionState,
          charactersGameState: charactersGameState,
          weaponsGameState: weaponsGameState,
          roomsGameState: roomsGameState,
          cellColoursState: cellBackgroundColourState,
        )
    );
  }

  _mainBody() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(0),
          sliver: SliverAppBar(
            leadingWidth: 0,
            automaticallyImplyLeading: false,
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Column(
                children: [
                  const Divider(
                    height: 3,
                    thickness: 3,
                    endIndent: 0,
                    color: ConstantUtils.primaryAppColor,
                  ),
                  _playerNamesHeaderPinned(),
                  const Divider(
                    height: 3,
                    thickness: 3,
                    endIndent: 0,
                    color: ConstantUtils.primaryAppColor,
                  )
                ],
              ),
            ),
          ),
        ),
        SliverList.list(
          children: [
            Row(
              children: [
                _generateEntityNamesList(),
                SizedBox(
                  height: ((ConstantUtils.CELL_SIZE_DEFAULT * ConstantUtils.allEntitites.length ) +
                      (10 * ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT)).toDouble(),
                  child: _verticalDivider(),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) * 2/3,
                      maxWidth: (min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) * 2) + (min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) / 3),
                    ),
                    child: _generateEntityMarkings(),
                  ),
                ),
              ],
            )
          ],

        ),
      ],
    );
  }

  _generateEntityNamesList() {
    return SizedBox(
      width: min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) / 4,
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
                            fontSize: 15,
                            color: noPlayersHaveThisCard(EntityType.Character, currentEntity) ? Colors.red : null,
                            decoration: anyPlayerHasThisCard(EntityType.Character, currentEntity) ? TextDecoration.lineThrough : null,
                            decorationColor: ConstantUtils.primaryAppColor,
                            decorationThickness: 3,
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
                        fontSize: 15,
                          color: noPlayersHaveThisCard(EntityType.Weapon, currentEntity) ? Colors.red : null,
                          decoration: anyPlayerHasThisCard(EntityType.Weapon, currentEntity) ? TextDecoration.lineThrough : null,
                          decorationColor: ConstantUtils.primaryAppColor,
                          decorationThickness: 3,
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
                        fontSize: 15,
                        color: noPlayersHaveThisCard(EntityType.Room, currentEntity) ? Colors.red : null,
                        decoration: anyPlayerHasThisCard(EntityType.Room, currentEntity) ? TextDecoration.lineThrough : null,
                        decorationColor: ConstantUtils.primaryAppColor,
                        decorationThickness: 3,
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

  bool anyPlayerHasThisCard(EntityType entityType, String currentEntity) {
    if (entityType == EntityType.Room) {
      return gameDefinitionState.playerNames.entries
          .map((e) => e.value)
          .map((e) => roomsGameState[currentEntity]![e]!.contains(ConstantUtils.tick))
          .reduce((value, element) => value || element);
    }
    else if (entityType == EntityType.Weapon) {
      return gameDefinitionState.playerNames.entries
          .map((e) => e.value)
          .map((e) => weaponsGameState[currentEntity]![e]!.contains(ConstantUtils.tick))
          .reduce((value, element) => value || element);
    }
    else {
      return gameDefinitionState.playerNames.entries
          .map((e) => e.value)
          .map((e) => charactersGameState[currentEntity]![e]!.contains(ConstantUtils.tick))
          .reduce((value, element) => value || element);
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

  _showEditGameNameDialog() {
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
                  title: const Text("Edit game name", style: TextStyle(color: ConstantUtils.primaryAppColor),),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (text) {
                        editedGameNameValue = text.trim();
                      },
                      initialValue: gameDefinitionState.gameName,
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
      if (editedGameNameValue != null) {
        _updateGameName(editedGameNameValue!);
      }
    });
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
                        editedPlayerNameValue = text.trim();
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
      if (editedPlayerNameValue != null) {
        _updatePlayerName(editedPlayerNameValue!, currentPlayerName, currentPlayerNameId);
      }
    });
  }

  _updateGameName(String newValue) {
    setState(() {
      gameDefinitionState = GameDefinition(
          gameId: gameDefinitionState.gameId,
          gameName: newValue,
          totalPlayers: gameDefinitionState.totalPlayers,
          playerNames: gameDefinitionState.playerNames,
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
          gameBackgroundColorState: cellBackgroundColourState,
          undoStack: undoStack,
          redoStack: redoStack,
        )
    );
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
          gameBackgroundColorState: cellBackgroundColourState,
          undoStack: undoStack,
          redoStack: redoStack,
        )
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
                final currentSelectedColor = Color(cellBackgroundColourState[currentEntity]![currentPlayerName]!);
                return [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onLongPress: () {
                        _showBackgroundColourSelectDialog(EntityType.Room, currentEntity, currentPlayerName, currentSelectedColor);
                      },
                      onTap: () {
                        final currentMarkings = roomsGameState[currentEntity]![currentPlayerName]!;
                        // Only show dialog select if not an initial card from GameDefinition
                        if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                            !roomsGameState[currentEntity]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                          _showMarkerSelectDialog(EntityType.Room, currentEntity, currentPlayerName, currentMarkings);
                        }
                        else {
                          SnackbarUtils.showSnackBarMedium(context, "Cannot modify markings here as this is initial game info! Long press to change background colour if needed.");
                        }
                      },
                      child: Card(
                        color: Color(cellBackgroundColourState[currentEntity]![currentPlayerName]!),
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

  _playerNamesHeaderPinned() {
    final maxCardsPerPlayer =
    ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / widget.gameDefinition.totalPlayers).floor();
    return Row(
      children: [
        SizedBox(
          width: (min(ScreenUtils.getScreenWidth(context), ScreenUtils.getMinimumScreenWidth()) / 4) ,
          height: 50,
          child: Container(
            color: Colors.grey.shade200,
          ),
        ),
        SizedBox(
          child: _verticalDivider(),
        ),
        Expanded(
          child: SizedBox(
            height: 50,
            child: Column(
              children: [
                Row(
                  children: playerNameMapEntries.map((e) => e.value).map((currentPlayerName) {

                    final knownWeapons = weaponsGameState.entries.where((entry) {
                      return entry.value[currentPlayerName]!.contains(ConstantUtils.tick);
                    });
                    final knownRooms = roomsGameState.entries.where((entry) {
                      return entry.value[currentPlayerName]!.contains(ConstantUtils.tick);
                    });
                    final knownCharacters = charactersGameState.entries.where((entry) {
                      return entry.value[currentPlayerName]!.contains(ConstantUtils.tick);
                    });
                    final knownCards = knownCharacters.length + knownRooms.length + knownWeapons.length;

                    return [
                      Expanded(
                        flex:  3,
                        child: InkWell(
                          onTap: () {
                            _showEditPlayerNameDialog(currentPlayerName);
                          },
                          child: Column(
                            children: [
                              Container(
                                  color: Colors.grey.shade200,
                                  width: double.infinity,
                                  child: WidgetUtils.spacer(2.5)
                              ),
                              Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currentPlayerName.split(ConstantUtils.UNIQUE_NAME_DELIMITER).firstOrNull ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.grey.shade200,
                                width: double.infinity,
                                child: WidgetUtils.spacer(3.5)
                              ),
                              Container(
                                color: Colors.grey.shade200,
                                height: 15,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    backgroundColor: knownCards == 0 ? Colors.red : (knownCards == maxCardsPerPlayer ? Colors.teal : Colors.orange) ,
                                    child: Text(
                                      "${knownCards}/${maxCardsPerPlayer}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 8,
                                        color: Colors.white
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                  color: Colors.grey.shade200,
                                  width: double.infinity,
                                  child: WidgetUtils.spacer(3.5)
                              ),
                            ],
                          ),
                        ),
                      ),
                      _verticalDivider2(),
                    ];
                  }).expand((element) => element).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _playerNamesHeader() {
    return SizedBox(
      height: 20,
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
                  // child: Center(
                  //   child: Text(
                  //     currentPlayerName.split(ConstantUtils.UNIQUE_NAME_DELIMITER).firstOrNull ?? "",
                  //     style: const TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //       fontSize: 12
                  //     ),
                  //   ),
                  // ),
                ),
              ),
            ),
            _verticalDivider2()
          ];
        }).expand((element) => element).toList(),
      ),
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
                final currentSelectedColor = Color(cellBackgroundColourState[currentEntity]![currentPlayerName]!);
                return [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onLongPress: () {
                        _showBackgroundColourSelectDialog(EntityType.Weapon, currentEntity, currentPlayerName, currentSelectedColor);
                      },
                      onTap: () {
                        final currentMarkings = weaponsGameState[currentEntity]![currentPlayerName]!;
                        if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                            !weaponsGameState[currentEntity]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                          _showMarkerSelectDialog(EntityType.Weapon, currentEntity, currentPlayerName, currentMarkings);
                        }
                        else {
                          SnackbarUtils.showSnackBarMedium(context, "Cannot modify markings here as this is initial game info! Long press to change background colour if needed.");
                        }
                      },
                      child: Card(
                        color: Color(cellBackgroundColourState[currentEntity]![currentPlayerName]!),
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
              children: playerNameMapEntries.map((e) => e.value).toList().asMap().map((index, currentPlayerName) {
                final currentSelectedColor = Color(cellBackgroundColourState[currentCharacter]![currentPlayerName]!);
                return MapEntry(
                    index,
                    [
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onLongPress: () {
                            _showBackgroundColourSelectDialog(EntityType.Weapon, currentCharacter, currentPlayerName, currentSelectedColor);
                          },
                          onTap: () {
                            final currentMarkings = charactersGameState[currentCharacter]![currentPlayerName]!;
                            // Check if we are not changing anything from initiral state
                            if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                                !charactersGameState[currentCharacter]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick)) {
                              _showMarkerSelectDialog(EntityType.Character, currentCharacter, currentPlayerName, currentMarkings);
                            }
                            else {
                              SnackbarUtils.showSnackBarMedium(context, "Cannot modify markings here as this is initial game info! Long press to change background colour if needed.");
                            }
                          },
                          child: Card(
                            key: index == 1 && currentCharacter == ConstantUtils.characterList[0] ? cell1Key :
                                (index == 1 && currentCharacter == ConstantUtils.characterList[1] ? cell2Key : null),
                            color: Color(cellBackgroundColourState[currentCharacter]![currentPlayerName]!),
                            child: _fillInCharacterCellContentsBasedOnState(currentCharacter, currentPlayerName),
                          ),
                        ),
                      ),
                      _verticalDivider2()
                    ]
                );
              }).entries.map((e) => e.value).expand((element) => element).toList(),
            ),
          );
        }
    );
  }

  _renderAllOtherMarkings(List<Widget> children) {
    return Center(
      child: CustomMarkingsLayout(
        children: children,
      ),
    );
  }

  _fillInCharacterCellContentsBasedOnState(String currentCharacter, String playerName) {
    if (charactersGameState[currentCharacter]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return _renderAllOtherMarkings(
          (
              charactersGameState[currentCharacter]?[playerName] ?? [])
              .map((marking) {
                if (marking == ConstantUtils.tick) {
                  return _maybeMarker2IconTick(marking, () {
                    charactersGameState[currentCharacter]![playerName] =
                    List.from(charactersGameState[currentCharacter]?[playerName] ?? [])..remove(marking);
                  });
                }
                else if (marking == ConstantUtils.cross) {
                  return _maybeMarker2IconCross(marking, () {
                    charactersGameState[currentCharacter]![playerName] =
                    List.from(charactersGameState[currentCharacter]?[playerName] ?? [])..remove(marking);
                  });
                }
                else if (marking == ConstantUtils.questionMark) {
                  return _maybeMarker2IconWarn(marking, () {
                    charactersGameState[currentCharacter]![playerName] =
                    List.from(charactersGameState[currentCharacter]?[playerName] ?? [])..remove(marking);
                  });
                }
                else {
                  return _maybeMarker2(marking, () {
                    charactersGameState[currentCharacter]![playerName] =
                    List.from(charactersGameState[currentCharacter]?[playerName] ?? [])..remove(marking);
                  });
                }
          }).toList()
      );
    }
    else {
      return Center(
        child: Container(),
      );
    }
  }

  _fillInRoomCellContentsBasedOnState(String currentRoom, String playerName) {
    if (roomsGameState[currentRoom]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return _renderAllOtherMarkings(
          (
              roomsGameState[currentRoom]?[playerName] ?? [])
              .map((marking) {

            if (marking == ConstantUtils.tick) {
              return _maybeMarker2IconTick(marking, () {
                roomsGameState[currentRoom]![playerName] =
                List.from(roomsGameState[currentRoom]?[playerName] ?? [])..remove(marking);
              });
            }
            else if (marking == ConstantUtils.cross) {
              return _maybeMarker2IconCross(marking, () {
                roomsGameState[currentRoom]![playerName] =
                List.from(roomsGameState[currentRoom]?[playerName] ?? [])..remove(marking);
              });
            }
            else if (marking == ConstantUtils.questionMark) {
              return _maybeMarker2IconWarn(marking, () {
                roomsGameState[currentRoom]![playerName] =
                List.from(roomsGameState[currentRoom]?[playerName] ?? [])..remove(marking);
              });
            }
            else {
              return _maybeMarker2(marking, () {
                roomsGameState[currentRoom]![playerName] =
                List.from(roomsGameState[currentRoom]?[playerName] ?? [])..remove(marking);
              });
            }


          }).toList()
      );
    }
    else {
      return Center(
        child: Container(),
      );
    }
  }

  _fillInWeaponCellContentsBasedOnState(String currentWeapon, String playerName) {
    if (weaponsGameState[currentWeapon]?[playerName]?.isNotEmpty ?? false) {
      // Something has been selected
      return _renderAllOtherMarkings(
          (weaponsGameState[currentWeapon]?[playerName] ?? [])
              .map((marking) {

            if (marking == ConstantUtils.tick) {
              return _maybeMarker2IconTick(marking, () {
                weaponsGameState[currentWeapon]![playerName] =
                List.from(weaponsGameState[currentWeapon]?[playerName] ?? [])..remove(marking);
              });
            }
            else if (marking == ConstantUtils.cross) {
              return _maybeMarker2IconCross(marking, () {
                weaponsGameState[currentWeapon]![playerName] =
                List.from(weaponsGameState[currentWeapon]?[playerName] ?? [])..remove(marking);
              });
            }
            else if (marking == ConstantUtils.questionMark) {
              return _maybeMarker2IconWarn(marking, () {
                weaponsGameState[currentWeapon]![playerName] =
                List.from(weaponsGameState[currentWeapon]?[playerName] ?? [])..remove(marking);
              });
            }
            else {
              return _maybeMarker2(marking, () {
                weaponsGameState[currentWeapon]![playerName] =
                List.from(weaponsGameState[currentWeapon]?[playerName] ?? [])..remove(marking);
              });
            }
          }).toList()
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
      width: 2,
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
            fontSize: 16
        ),
      ),
    );
  }

  _markCellBackgroundColourDialogAsClosedAndResetBackground(EntityType entityType, String currentEntity, String currentPlayerName) {
    cellBackgroundColourState[currentEntity]?[currentPlayerName] = Colors.grey.shade200.value;

    _mainGameBloc.add(
        MainGameStateChanged(
          initialGame: gameDefinitionState,
          charactersGameState: charactersGameState,
          weaponsGameState: weaponsGameState,
          roomsGameState: roomsGameState,
          gameBackgroundColorState: cellBackgroundColourState,
          undoStack: undoStack,
          redoStack: redoStack,
        )
    );
    setState(() {
      isBackgroundColourDialogOpen = false;
      selectedBackgroundColourFromDialog = null;
    });
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
          gameBackgroundColorState: cellBackgroundColourState,
          undoStack: undoStack,
          redoStack: redoStack,
        )
    );
    setState(() {
      isMarkingDialogOpen = false;
      selectedMarkingFromDialog = null;
    });
  }

  _markCellBackgroundColourDialogDialogAsClosedAndSaveBackgoundColour(EntityType entityType, String currentEntity, String currentPlayerName) {
    if (selectedBackgroundColourFromDialog != null) {
      KeyboardUtils.lightImpact();
      cellBackgroundColourState[currentEntity]![currentPlayerName] = selectedBackgroundColourFromDialog!.value;

      _mainGameBloc.add(
          MainGameStateChanged(
            initialGame: gameDefinitionState,
            charactersGameState: charactersGameState,
            weaponsGameState: weaponsGameState,
            roomsGameState: roomsGameState,
            gameBackgroundColorState: cellBackgroundColourState,
            undoStack: undoStack,
            redoStack: redoStack,
          )
      );
      setState(() {
        isBackgroundColourDialogOpen = false;
        selectedBackgroundColourFromDialog = null;
      });
    }
  }

  _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(
      EntityType entityType,
      String currentPlayerName,
      String currentEntity,
      ) {
    final knownWeapons = weaponsGameState.entries.where((entry) {
      return entry.value[currentPlayerName]!.contains(ConstantUtils.tick);
    });
    final knownRooms = roomsGameState.entries.where((entry) {
      return entry.value[currentPlayerName]!.contains(ConstantUtils.tick);
    });
    final knownCharacters = charactersGameState.entries.where((entry) {
      return entry.value[currentPlayerName]!.contains(ConstantUtils.tick);
    });
    final knownCards = knownCharacters.length + knownRooms.length + knownWeapons.length;
    final maxCardsPerPlayer =
    ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / widget.gameDefinition.totalPlayers).floor();

    if (knownCards == maxCardsPerPlayer) {
      _showInferenceConfirmationDialog(
          entityType,
          currentEntity,
          currentPlayerName,
          _inferNoOtherRemainingCardsToDiscoverForCurrentPlayerConfirmationText(currentPlayerName, currentEntity),
              () {
            _markAllOtherCardsForCurrentPlayerAsNotHaving(entityType, currentPlayerName, currentEntity);
          }
      );
    }
  }

  _markAllOtherRoomsAsMissing(String currentPlayerName, String currentEntity) {
    GameState tempRooms = {};
    roomsGameState.forEach((key, value) {
      final newVal = {
        ...value,
        currentPlayerName: !(value[currentPlayerName]!.contains(ConstantUtils.tick) || value[currentPlayerName]!.contains(ConstantUtils.cross)) ?
        [...value[currentPlayerName]!, ConstantUtils.cross] : value[currentPlayerName]!
      };
      tempRooms[key] = newVal;
    });
    roomsGameState = tempRooms;
  }

  _markAllOtherWeaponsMissing(String currentPlayerName, String currentEntity) {
    GameState temp = {};
    weaponsGameState.forEach((key, value) {
      final newVal = {
        ...value,
        currentPlayerName: !(value[currentPlayerName]!.contains(ConstantUtils.tick) || value[currentPlayerName]!.contains(ConstantUtils.cross)) ?
        [...value[currentPlayerName]!, ConstantUtils.cross] : value[currentPlayerName]!
      };
      temp[key] = newVal;
    });
    weaponsGameState = temp;
  }

  _markAllOtherCharactersMissing(String currentPlayerName, String currentEntity) {
    GameState temp = {};
    charactersGameState.forEach((key, value) {
      final newVal = {
        ...value,
        currentPlayerName: !(value[currentPlayerName]!.contains(ConstantUtils.tick) || value[currentPlayerName]!.contains(ConstantUtils.cross)) ?
        [...value[currentPlayerName]!, ConstantUtils.cross] : value[currentPlayerName]!
      };
      temp[key] = newVal;
    });
    charactersGameState = temp;
  }

  /// Marks all other "unknown" cards for the user as not having
  /// If there is tick or cross already on it, it is untouched
  /// Otherwise a cross is added to markings list
  _markAllOtherCardsForCurrentPlayerAsNotHaving(EntityType entityType, String currentPlayerName, String currentEntity) {
    setState(() {
      _markAllOtherCharactersMissing(currentPlayerName, currentEntity);
      _markAllOtherRoomsAsMissing(currentPlayerName, currentEntity);
      _markAllOtherWeaponsMissing(currentPlayerName, currentEntity);
    });
  }

  _markAllOtherPlayersAsNotHavingCharacterCard(String currentPlayerName, String currentEntity) {
    setState(() {
      // If it is a tick, then others all get a CROSS added as only one person can own a card at a time
      final allPlayersExceptCurrent =
      gameDefinitionState.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
      allPlayersExceptCurrent.forEach((element) {
        charactersGameState[currentEntity]?[element] =
        List.from(charactersGameState[currentEntity]![element]!)..remove(ConstantUtils.cross)..add(ConstantUtils.cross);
      });
    });
  }

  _markAllOtherPlayersAsNotHavingWeaponCard(String currentPlayerName, String currentEntity) {
    setState(() {
      // If it is a tick, then others all get a CROSS added as only one person can own a card at a time
      final allPlayersExceptCurrent =
      gameDefinitionState.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
      allPlayersExceptCurrent.forEach((element) {
        weaponsGameState[currentEntity]?[element] =
        List.from(weaponsGameState[currentEntity]![element]!)..remove(ConstantUtils.cross)..add(ConstantUtils.cross);
      });
    });
  }

  _markAllOtherPlayersAsNotHavingRoomCard(String currentPlayerName, String currentEntity) {
    setState(() {
      // If it is a tick, then others all get a CROSS added as only one person can own a card at a time
      final allPlayersExceptCurrent =
      gameDefinitionState.playerNames.entries.map((e) => e.value).where((element) => element != currentPlayerName);
      allPlayersExceptCurrent.forEach((element) {
        roomsGameState[currentEntity]?[element] =
        List.from(roomsGameState[currentEntity]![element]!)..remove(ConstantUtils.cross)..add(ConstantUtils.cross);
      });
    });
  }

  _refinedPlayerName(String currentPlayerName) =>
      currentPlayerName.split(ConstantUtils.UNIQUE_NAME_DELIMITER).firstOrNull ?? "";

  _inferNoOtherPlayerHasThisCardConfirmationText(String currentPlayerName, String currentEntity) {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: "Since you have confirmed that ",
            style: const TextStyle(
                color: ConstantUtils.primaryAppColor,
                fontSize: 16
            ),
            children: [
              TextSpan(
                  text: _refinedPlayerName(currentPlayerName),
                  style: const TextStyle(
                      color: ConstantUtils.primaryAppColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              const TextSpan(
                  text: " has the ",
                  style: TextStyle(
                    color: ConstantUtils.primaryAppColor,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: currentEntity,
                  style: const TextStyle(
                      color: ConstantUtils.primaryAppColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              const TextSpan(
                  text: " card, we infer that no other player has it!\n\nHit confirm if you'd like to mark all other players as not having this card.",
                  style: TextStyle(
                    color: ConstantUtils.primaryAppColor,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
            ]
        )
    );
  }

  _inferNoOtherRemainingCardsToDiscoverForCurrentPlayerConfirmationText(String currentPlayerName, String currentEntity) {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: "Since you have confirmed that ",
            style: const TextStyle(
                color: ConstantUtils.primaryAppColor,
                fontSize: 16
            ),
            children: [
              TextSpan(
                  text: _refinedPlayerName(currentPlayerName),
                  style: const TextStyle(
                      color: ConstantUtils.primaryAppColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              const TextSpan(
                  text: " has the ",
                  style: TextStyle(
                    color: ConstantUtils.primaryAppColor,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: currentEntity,
                  style: const TextStyle(
                      color: ConstantUtils.primaryAppColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              const TextSpan(
                  text: " card, we now know all the cards they posses!\n\nHit confirm if you'd like to mark all other cards for this player as missing.",
                  style: TextStyle(
                    color: ConstantUtils.primaryAppColor,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
            ]
        )
    );
  }

  _markDialogAsClosedAndSaveMarking(EntityType entityType, String currentEntity, String currentPlayerName) {
    if (selectedMarkingFromDialog != null) {
      KeyboardUtils.lightImpact();

      // Something was selected, persist it
      if (entityType == EntityType.Character) {
        if (selectedMarkingFromDialog == ConstantUtils.tick) {
          if (charactersGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            // do nothing as we are removing
          }
          else {
            // We are adding a Tick over here. Ask user for confirmation to infer
            _showInferenceConfirmationDialog(
              entityType,
              currentEntity,
              currentPlayerName,
              _inferNoOtherPlayerHasThisCardConfirmationText(currentPlayerName, currentEntity),
              () {
                _markAllOtherPlayersAsNotHavingCharacterCard(currentPlayerName, currentEntity);
                _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
              }
            );
          }
        }
        // else {
          // charactersGameState[currentEntity]?[currentPlayerName]?.remove(ConstantUtils.tick);
          // charactersGameState[currentEntity]?[currentPlayerName]?.remove(ConstantUtils.cross);
          if (charactersGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            charactersGameState[currentEntity]?[currentPlayerName]?.remove(selectedMarkingFromDialog);
          }
          else {
            if ((charactersGameState[currentEntity]?[currentPlayerName]?.length ?? 0) >= ConstantUtils.MAX_MARKINGS) {
              charactersGameState[currentEntity]?[currentPlayerName]?.removeAt(0);
            }
            charactersGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog!);
          }
        // }
      }
      else if (entityType == EntityType.Weapon) {
        if (selectedMarkingFromDialog == ConstantUtils.tick) {
          if (weaponsGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            // do nothing as we are removing
          }
          else {
            // We are adding a Tick over here. Ask user for confirmation to infer
            _showInferenceConfirmationDialog(
                entityType,
                currentEntity,
                currentPlayerName,
                _inferNoOtherPlayerHasThisCardConfirmationText(currentPlayerName, currentEntity),
                    () {
                  _markAllOtherPlayersAsNotHavingWeaponCard(currentPlayerName, currentEntity);
                  _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
                }
            );
          }
        }
        // else {
          if (weaponsGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            weaponsGameState[currentEntity]?[currentPlayerName]?.remove(selectedMarkingFromDialog);
          }
          else {
            if ((weaponsGameState[currentEntity]?[currentPlayerName]?.length ?? 0) >= ConstantUtils.MAX_MARKINGS) {
              weaponsGameState[currentEntity]?[currentPlayerName]?.removeAt(0);
            }
            weaponsGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog!);
          }
        // }
      }
      else {
        if (selectedMarkingFromDialog == ConstantUtils.tick) {
          if (roomsGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            // do nothing as we are removing
          }
          else {
            // We are adding a Tick over here. Ask user for confirmation to infer
            _showInferenceConfirmationDialog(
                entityType,
                currentEntity,
                currentPlayerName,
                _inferNoOtherPlayerHasThisCardConfirmationText(currentPlayerName, currentEntity),
                    () {
                  _markAllOtherPlayersAsNotHavingRoomCard(currentPlayerName, currentEntity);
                  _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
                }
            );
          }
        }
        // else {
          if (roomsGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
            roomsGameState[currentEntity]?[currentPlayerName]?.remove(selectedMarkingFromDialog);
          }
          else {
            if ((roomsGameState[currentEntity]?[currentPlayerName]?.length ?? 0) >= ConstantUtils.MAX_MARKINGS) {
              roomsGameState[currentEntity]?[currentPlayerName]?.removeAt(0);
            }
            roomsGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog!);
          }
        // }
      }

      _mainGameBloc.add(
          MainGameStateChanged(
            initialGame: gameDefinitionState,
            charactersGameState: charactersGameState,
            weaponsGameState: weaponsGameState,
            roomsGameState: roomsGameState,
            gameBackgroundColorState: cellBackgroundColourState,
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
    KeyboardUtils.lightImpact();

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
          appBar: null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(
                    child: Text(
                      "Current markings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ConstantUtils.primaryAppColor
                      ),
                    ),
                  ),
                ),
                WidgetUtils.spacer(2.5),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(
                          color: ConstantUtils.primaryAppColor,
                          width: 2.5
                      )
                  ),
                  child: SizedBox(
                    height: 120,
                    child: currentMarkings.isEmpty ? Container() : CustomMarkingsLayout(
                      isPartOfDialog: true,
                      children: currentMarkings.map((marking) {
                        return _maybeMarkerVanilla(marking, () {
                          _setStateAndPop(marking, context);
                        });
                      }).toList(),
                    ),
                  ),
                ),
                WidgetUtils.spacer(2.5),
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
                    "Symbols",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ConstantUtils.primaryAppColor,
                        fontSize: 16,
                    ),
                ),
                WidgetUtils.spacer(2.5),
                Row(
                  children: [
                    Expanded(
                        // Check marker
                        child: SizedBox(
                          width: 40,
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
                          width: 40,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMarkingFromDialog = ConstantUtils.questionMark;
                              });
                              Navigator.pop(context);
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.amber,
                              child: Icon(Icons.warning, size: 16, color: Colors.white,),
                            ),
                          ),
                        )
                    ),
                    Expanded(
                      // Cross marker
                        child: SizedBox(
                          width: 40,
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
                  crossAxisCount: ScreenUtils.isPortraitOrientation(context) ? 6 : 12,
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
                  crossAxisCount: ScreenUtils.isPortraitOrientation(context) ? 6 : 12,
                  children: [
                    _maybeMarker("A", currentMarkings.contains("A"), () {
                      _setStateAndPop("A", context);
                    }),
                    _maybeMarker("B", currentMarkings.contains("B"), () {
                      _setStateAndPop("B", context);
                    }),
                    _maybeMarker("C", currentMarkings.contains("C"),  () {
                      _setStateAndPop("C", context);
                    }),
                    _maybeMarker("D", currentMarkings.contains("D"), () {
                      _setStateAndPop("D", context);
                    }),
                    _maybeMarker("E", currentMarkings.contains("E"),  () {
                      _setStateAndPop("E", context);
                    }),
                    _maybeMarker("F", currentMarkings.contains("F"),  () {
                      _setStateAndPop("F", context);
                    }),
                    _maybeMarker("G", currentMarkings.contains("G"),  () {
                      _setStateAndPop("G", context);
                    }),
                    _maybeMarker("H", currentMarkings.contains("H"),  () {
                      _setStateAndPop("H", context);
                    }),
                    _maybeMarker("I", currentMarkings.contains("I"),  () {
                      _setStateAndPop("I", context);
                    }),
                    _maybeMarker("J", currentMarkings.contains("J"),  () {
                      _setStateAndPop("J", context);
                    }),
                    _maybeMarker("K", currentMarkings.contains("K"),  () {
                      _setStateAndPop("K", context);
                    }),
                    _maybeMarker("L", currentMarkings.contains("L"),  () {
                      _setStateAndPop("L", context);
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

  _showBackgroundColourSelectDialog(
      EntityType entityType,
      String currentEntity,
      String currentPlayerName,
      Color currentSelectedColour
      ) {

    KeyboardUtils.mediumImpact();

    setState(() {
      isBackgroundColourDialogOpen = true;
    });

    _resetCellButton() {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(ConstantUtils.primaryAppColor),
          ),
          onPressed: () async {
            _markCellBackgroundColourDialogAsClosedAndResetBackground(entityType, currentEntity, currentPlayerName);
            Navigator.pop(context);
          },
          child: const Text("Reset colour", style: TextStyle(fontSize: 15, color: Colors.white)),
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
            _markCellBackgroundColourDialogDialogAsClosedAndSaveBackgoundColour(entityType, currentEntity, currentPlayerName);
            Navigator.pop(context);
          },
          child: const Text("Go back", style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      );
    }

    showDialog(context: context, builder: (context) {
      return Dialog(
        child:  SizedBox(
          height: ScreenUtils.getScreenHeight(context) / 2,
          child: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Center(
                        child: Text(
                          "Select the colour you want to change the cell background to",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: ConstantUtils.primaryAppColor
                          ),
                        ),
                      ),
                    ),
                    WidgetUtils.spacer(5),
                    _divider(),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 6,
                      children: ConstantUtils.cellBackgroundColorOptions.map((c) {
                        return _colorMarker(c, currentSelectedColour == c, () {
                          _setBackgroundColourStateAndPop(c, context);
                        });
                      }).toList(),
                    ),
                    WidgetUtils.spacer(2.5),
                    _divider(),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                    width: 20,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: GestureDetector(
                                        child: Container(
                                          child: CircleAvatar(
                                            backgroundColor: currentSelectedColour,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              ),
                              const Expanded(
                                  child: Text(
                                    "Current selection",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: ConstantUtils.primaryAppColor,
                                        fontWeight: FontWeight.w500
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(),
                        )
                      ],
                    ),
                    WidgetUtils.spacer(2.5),
                    _divider(),
                  ],
                ),
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
        ),
      );
    }).then((value) => _markCellBackgroundColourDialogDialogAsClosedAndSaveBackgoundColour(entityType, currentEntity, currentPlayerName));
  }


  _showInferenceConfirmationDialog(
      EntityType entityType,
      String currentEntity,
      String currentPlayerName,
      Widget confirmationTextWidget,
      VoidCallback ifInferPermissionGranted
      ) {

    KeyboardUtils.mediumImpact();

    setState(() {
      isInferenceConfirmationDialogOpen = true;
    });

    _confirmInferenceButton() {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(ConstantUtils.primaryAppColor),
          ),
          onPressed: () async {
            Navigator.pop(context, true);
          },
          child: const Text("Confirm", style: TextStyle(fontSize: 15, color: Colors.white)),
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
            Navigator.pop(context, false);
          },
          child: const Text("Cancel", style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog<bool>(context: context, builder: (context) {
        return Dialog(
          child:  SizedBox(
            height: ScreenUtils.getScreenHeight(context) / 2,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Center(child: Text("Confirm Inference", style: TextStyle(color: ConstantUtils.primaryAppColor),)),
                iconTheme: const IconThemeData(
                  color: ConstantUtils.primaryAppColor,
                ),
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _divider(),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: confirmationTextWidget
                        ),
                      ),
                      WidgetUtils.spacer(2.5),
                      _divider(),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Row(
                children: [
                  Expanded(
                    child: _dismissDialogButton(),
                  ),
                  Expanded(
                    child: _confirmInferenceButton(),
                  ),
                ],
              ),
            ),
          ),
        );
      }).then((value) {
        if (value ?? false) {
          ifInferPermissionGranted();
        }
      });
    });
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

  _setBackgroundColourStateAndPop(Color selectedColor, BuildContext context) {
    setState(() {
      selectedBackgroundColourFromDialog = selectedColor;
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

  Widget _colorMarker(Color color, bool isSelectedAlready, VoidCallback onTap) {
    return SizedBox(
      width: 30,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all( Radius.circular(50.0)),
              border: Border.all(
                color: isSelectedAlready ? ConstantUtils.primaryAppColor : Colors.transparent,
                width: 4.0,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _maybeMarkerVanilla(String text, VoidCallback onTap) {
    if (text == ConstantUtils.tick) {
      return SizedBox(
        width: 50,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: onTap,
              child: const CircleAvatar(
                child: Icon(Icons.check, size: ConstantUtils.MARKING_ICON_DIAMETER_2,),
              )
          ),
        ),
      );

    }
    else if (text == ConstantUtils.cross) {
      return SizedBox(
        width: 50,
        child: Padding(
          padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: onTap,
              child: const CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.close, size: ConstantUtils.MARKING_ICON_DIAMETER_2, color: Colors.white,),
              ),
            )
        ),
      );

    }
    else if (text == ConstantUtils.questionMark) {
      return SizedBox(
        width: 50,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: onTap,
              child: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.warning, size: ConstantUtils.MARKING_ICON_DIAMETER_2, color: Colors.white,),
              ),
            )
        ),
      );
    }
    else {
      return SizedBox(
        width: 50,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: ConstantUtils.primaryAppColor
                  )
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _maybeMarker2(String text, VoidCallback onTap) {
    return SizedBox(
      width: ConstantUtils.MARKING_DIAMETER,
      height: ConstantUtils.MARKING_DIAMETER,
      child: GestureDetector(
        // onTap: onTap,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(
              text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: ConstantUtils.primaryAppColor
            ),
          ),
        ),
      ),
    );
  }

  Widget _maybeMarker2IconTick(String text, VoidCallback onTap) {
    return const SizedBox(
        width: ConstantUtils.MARKING_DIAMETER,
        height: ConstantUtils.MARKING_DIAMETER,
        child: CircleAvatar(
          child: Icon(Icons.check, size: ConstantUtils.MARKING_ICON_DIAMETER,),
        )
    );
  }

  Widget _maybeMarker2IconCross(String text, VoidCallback onTap) {
    return const SizedBox(
        width: ConstantUtils.MARKING_DIAMETER,
        height: ConstantUtils.MARKING_DIAMETER,
        child: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.close, size: ConstantUtils.MARKING_ICON_DIAMETER, color: Colors.white,),
        )
    );
  }

  Widget _maybeMarker2IconWarn(String text, VoidCallback onTap) {
    return const SizedBox(
        width: ConstantUtils.MARKING_DIAMETER,
        height: ConstantUtils.MARKING_DIAMETER,
        child: CircleAvatar(
          backgroundColor: Colors.amber,
          child: Icon(Icons.warning, size: ConstantUtils.MARKING_ICON_DIAMETER, color: Colors.white,),
        )
    );
  }
}