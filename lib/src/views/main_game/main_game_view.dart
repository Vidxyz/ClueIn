import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/game_conclusion.dart';
import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/models/stack.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/keyboard_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/snackbar_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_bloc.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_event.dart';
import 'package:cluein_app/src/views/main_game/bloc/main_game_state.dart';
import 'package:cluein_app/src/views/main_game/views/markings_view.dart';
import 'package:cluein_app/src/views/settings/settings_view.dart';
import 'package:cluein_app/src/views/shared_components/ads/custom_markings_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

GlobalKey cell1Key = GlobalKey();
GlobalKey cell2Key = GlobalKey();
GlobalKey cell3Key = GlobalKey();
GlobalKey undoKey = GlobalKey();
GlobalKey redoKey = GlobalKey();
GlobalKey gameNameTextKey = GlobalKey();
GlobalKey playerNameTextKey = GlobalKey();

enum EntityType { Character, Weapon, Room }
enum InferenceType { NoOtherPlayerHasThisCard, ThisPlayerHasNoOtherCards, MaxCardsKnownForEntityType }

class MainGameView extends StatefulWidget {
  static const String routeName = "game";

  final GameDefinition gameDefinition;
  final GameSettings gameSettings;

  const MainGameView({
    super.key,
    required this.gameDefinition,
    required this.gameSettings,
  });

  static Route<bool> route({
    required GameDefinition gameDefinition,
    required GameSettings gameSettings,
  }) => MaterialPageRoute(
    settings: const RouteSettings(
        name: routeName
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider<MainGameBloc>(
            create: (context) => MainGameBloc(
                sembast: RepositoryProvider.of<SembastRepository>(context),
            )),
      ],
      child: MainGameView(
        gameDefinition: gameDefinition,
        gameSettings: gameSettings,
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

  bool dontAskAgainForInferenceNoOtherPlayerHasThisCard = false;
  bool dontAskAgainForInferenceThisPlayerHasNoOtherCards = false;
  bool dontAskAgainForInferenceMaxCardsKnownForEntityType = false;

  List<String> selectedMarkingsFromDialog = [];
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

  Color primaryColorSettingState = ConstantUtils.primaryAppColor;
  bool selectMultipleMarkingsAtOnceSettingState = false;
  ClueVersion selectedClueVersionSetting = ConstantUtils.defaultClueVersion;

  int currentQuickMarkerIndex = 0;
  bool isScreenHidden = false;

  Timer? debounce;
  bool isSnackbarBeingShown = false;

  bool isGameOver = false;

  final ScrollController _scrollController = ScrollController();

  Map<String, String> cardDisplayNameMap = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

    primaryColorSettingState = widget.gameSettings.primaryColorSetting;
    selectMultipleMarkingsAtOnceSettingState = widget.gameSettings.selectMultipleMarkingsAtOnceSetting;
    selectedClueVersionSetting = widget.gameSettings.clueVersionSetting;

    cardDisplayNameMap = ConstantUtils.clueVersionToDisplayNameMap[selectedClueVersionSetting]!;
    
    initTutorial();
    _setupGameStateInitially();

    if (!widget.gameSettings.hasMandatoryTutorialBeenShown) {
      _performTutorial();
      _mainGameBloc.add(
          const MarkMandatoryTutorialAsComplete()
      );
    }
  }

  _tapAnywhereToContinue() {
    return const Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            "Tap anywhere to continue",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  initTutorial() {
    basicTargets.clear();

    // Intro screen
    basicTargets.add(
      TargetFocus(
        identify: "gameNameTextKey",
        keyTarget: gameNameTextKey,
        alignSkip: Alignment.topRight,
        color: primaryColorSettingState,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        enableTargetTab: true,
        paddingFocus: 0,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return SizedBox(
                height: ScreenUtils.getScreenHeight(context),
                child: Stack(
                  children: [
                    Column(
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
                              "When another player shows a card, it can typically be one of three options",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
                              "In this case, add a distinct new marking corresponding to the current round",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
                                fontWeight: FontWeight.bold,
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
                              "If there are multiple distinct markings over different rounds on the same card, that means the respective player could possess it.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        WidgetUtils.spacer(25),
                        _tapAnywhereToContinue()
                      ]),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    basicTargets.add(
      TargetFocus(
        identify: "cell1Key",
        keyTarget: cell1Key,
        alignSkip: Alignment.topRight,
        color: primaryColorSettingState,
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
                          fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  _tapAnywhereToContinue()
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
        color: primaryColorSettingState,
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
                          fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  _tapAnywhereToContinue()
                ]),
              );
            },
          ),
        ],
      ),
    );

    // Double tap
    basicTargets.add(
      TargetFocus(
        identify: "cell3Key",
        keyTarget: cell3Key,
        alignSkip: Alignment.topRight,
        color: primaryColorSettingState,
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
                      "Double tap on a cell to toggle between basic markers",
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
                        "This cycles through the 3 symbols available for selection in the dialog that pops up when a cell is tapped.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  _tapAnywhereToContinue()
                ]),
              );
            },
          ),
        ],
      ),
    );

    // Game name button
    basicTargets.add(
      TargetFocus(
        identify: "gameNameTextKey2",
        keyTarget: gameNameTextKey,
        alignSkip: Alignment.centerRight,
        color: primaryColorSettingState,
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
                      "Tap on the name of the game to change it",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  _tapAnywhereToContinue()
                ]),
              );
            },
          ),
        ],
      ),
    );

    // Player name button
    basicTargets.add(
      TargetFocus(
        identify: "playerNameTextKey",
        keyTarget: playerNameTextKey,
        alignSkip: Alignment.centerRight,
        color: primaryColorSettingState,
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
                      "Tap on a player's name to change it",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  _tapAnywhereToContinue()
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
        alignSkip: Alignment.centerRight,
        color: primaryColorSettingState,
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
                      "Tap here to undo your last move",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  _tapAnywhereToContinue()
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
        alignSkip: Alignment.centerRight,
        color: primaryColorSettingState,
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
                      "Tap here to redo your last move",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  WidgetUtils.spacer(25),
                  _tapAnywhereToContinue()
                ]),
              );
            },
          ),
        ],
      ),
    );


    basicTutorialCoachMark = TutorialCoachMark(
      targets: basicTargets,
      colorShadow: primaryColorSettingState,
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

  _toggleScreenHide() {
    setState(() {
      isScreenHidden = !isScreenHidden;
    });
  }

  _performUndo() {
    if (_canUndo()) {
      KeyboardUtils.lightImpact();
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

  _goToSettingsPage() {
    Navigator.push(
        context,
        SettingsView.route(
            GameSettings(
                primaryColorSetting: primaryColorSettingState,
                selectMultipleMarkingsAtOnceSetting: selectMultipleMarkingsAtOnceSettingState,
                hasMandatoryTutorialBeenShown: widget.gameSettings.hasMandatoryTutorialBeenShown,
                clueVersionSetting: selectedClueVersionSetting,
            )
        )
    ).then((value) {
      if (value != null) {
        setState(() {
          primaryColorSettingState = value.primaryColorSetting;
          selectMultipleMarkingsAtOnceSettingState = value.selectMultipleMarkingsAtOnceSetting;
          selectedClueVersionSetting = value.clueVersionSetting;
          cardDisplayNameMap = ConstantUtils.clueVersionToDisplayNameMap[selectedClueVersionSetting]!;
        });
        initTutorial();
      }
    });
  }

  _performTutorial() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    }
    basicTutorialCoachMark?.show(context: context);
  }

  _performRedo() {
    if (_canRedo()) {
      KeyboardUtils.lightImpact();
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
    final conclusion = generateConclusion();
    if (conclusion.isGameOver() && !isGameOver) {
      isGameOver = true;
      _updateBlocStateFromState();
      _mainGameBloc.add(const GameOverEvent());
    }
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            _showEditGameNameDialog();
          },
          child: Text(
            gameDefinitionState.gameName,
            key: gameNameTextKey,
            style: TextStyle(color: primaryColorSettingState),
          )
        ),
        iconTheme: IconThemeData(
          color: primaryColorSettingState,
        ),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     Icons.help,
          //     color: primaryColorSettingState,
          //   ),
          //   onPressed: _performTutorial,
          // ),
          IconButton(
            icon: Icon(
              Icons.remove_red_eye,
              color: isScreenHidden ? primaryColorSettingState : Colors.grey,
            ),
            onPressed: _toggleScreenHide,
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.settings,
          //     color: primaryColorSettingState,
          //   ),
          //   onPressed: _goToSettingsPage,
          // ),
          IconButton(
            key: undoKey,
            icon: Icon(
              Icons.undo,
              color: _canUndo() ? primaryColorSettingState : Colors.grey,
            ),
            onPressed: _performUndo,
          ),
          IconButton(
            key: redoKey,
            icon: Icon(
              Icons.redo,
              color: _canRedo() ? primaryColorSettingState : Colors.grey,
            ),
            onPressed: _performRedo,
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert, color: primaryColorSettingState),
            onSelected: (item) {
              switch (item) {
                case 0:
                  _goToSettingsPage();
                  break;
                case 1:
                  _performTutorial();
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Settings")
              ),
              const PopupMenuItem<int>(
                  value: 1,
                  child: Text("Help")
              ),
            ],
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

          if (state is GameOverState) {
            _showGameOverDialog(conclusion);
          }
        },
        child: _mainBody(),
      ),
    );
  }

  /// Returns true iff there are exactly 3 cards completely unnaccounted for ---> Weapon/Room/Character combo
  GameConclusion generateConclusion() {
    final Map<CharacterName, bool> characterReductionMap = charactersGameState.map((key, value) =>
        MapEntry(key, value.entries
            .map((e) => e.value.contains(ConstantUtils.cross))
            .reduce((value, element) => value && element))
    );

    final Map<CharacterName, bool> weaponReductionMap = weaponsGameState.map((key, value) =>
        MapEntry(key, value.entries
            .map((e) => e.value.contains(ConstantUtils.cross))
            .reduce((value, element) => value && element))
    );

    final Map<CharacterName, bool> roomReductionMap = roomsGameState.map((key, value) =>
        MapEntry(key, value.entries
            .map((e) => e.value.contains(ConstantUtils.cross))
            .reduce((value, element) => value && element))
    );

    final String? murderer = characterReductionMap.entries.where((element) => element.value).firstOrNull?.key;
    final String? room = roomReductionMap.entries.where((element) => element.value).firstOrNull?.key;
    final String? weapon = weaponReductionMap.entries.where((element) => element.value).firstOrNull?.key;

    return GameConclusion(character: murderer, room: room, weapon: weapon);
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

    setStateBasedOnPublicInfoCards() {
      // For all cards mentioned here, ecvery user is marked as not having it
      gameDefinitionState.publicInfoCards.forEach((element) {
        if (ConstantUtils.roomList.contains(element.cardName())) {
          roomsGameState[element.cardName()] = Map.fromEntries(
              gameDefinitionState
                  .playerNames
                  .entries
                  .map((e) => MapEntry(e.value, [ConstantUtils.noOneHasThis]))
          );
        }
        else if (ConstantUtils.characterList.contains(element.cardName())) {
            charactersGameState[element.cardName()] = Map.fromEntries(
                gameDefinitionState
                    .playerNames
                    .entries
                    .map((e) => MapEntry(e.value, [ConstantUtils.noOneHasThis]))
            );
        }
        else {
          weaponsGameState[element.cardName()] = Map.fromEntries(
          gameDefinitionState
              .playerNames
              .entries
              .map((e) => MapEntry(e.value, [ConstantUtils.noOneHasThis]))
          );
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
    setStateBasedOnPublicInfoCards();

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
    return ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: primaryColorSettingState,
        child: CustomScrollView(
          controller: _scrollController,
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
                      Divider(
                        height: 3,
                        thickness: 3,
                        endIndent: 0,
                        color: primaryColorSettingState,
                      ),
                      _playerNamesHeaderPinned(),
                      Divider(
                        height: 3,
                        thickness: 3,
                        endIndent: 0,
                        color: primaryColorSettingState,
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
        ),
      ),
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                          cardDisplayNameMap[currentEntity] ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: noPlayersHaveThisCard(EntityType.Character, currentEntity) ? FontWeight.bold : FontWeight.normal,
                              color: noPlayersHaveThisCard(EntityType.Character, currentEntity) ? Colors.red : null,
                              decoration: anyPlayerHasThisCardOrCardIsPublicInfo(EntityType.Character, currentEntity) ? TextDecoration.lineThrough : null,
                              decorationColor: primaryColorSettingState,
                              decorationThickness: 3,
                          ),
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                          cardDisplayNameMap[currentEntity] ?? "",
                          textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                            fontWeight: noPlayersHaveThisCard(EntityType.Weapon, currentEntity) ? FontWeight.bold : FontWeight.normal,
                            color: noPlayersHaveThisCard(EntityType.Weapon, currentEntity) ? Colors.red : null,
                            decoration: anyPlayerHasThisCardOrCardIsPublicInfo(EntityType.Weapon, currentEntity) ? TextDecoration.lineThrough : null,
                            decorationColor: primaryColorSettingState,
                            decorationThickness: 3,
                        ),
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        cardDisplayNameMap[currentEntity] ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: noPlayersHaveThisCard(EntityType.Room, currentEntity) ? FontWeight.bold : FontWeight.normal,
                          color: noPlayersHaveThisCard(EntityType.Room, currentEntity) ? Colors.red : null,
                          decoration: anyPlayerHasThisCardOrCardIsPublicInfo(EntityType.Room, currentEntity) ? TextDecoration.lineThrough : null,
                          decorationColor: primaryColorSettingState,
                          decorationThickness: 3,
                        ),
                      ),
                    )
                ),
              ),
            ),
          );
        }
    );
  }


  /// Returns false if screen is hidden
  bool noPlayersHaveThisCard(EntityType entityType, String currentEntity) {
    if (isScreenHidden) {
      return false;
    }

    if (entityType == EntityType.Room) {
      return playerNameMapEntries
          .map((e) => e.value)
          .map((e) => roomsGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
    else if (entityType == EntityType.Weapon) {
      return playerNameMapEntries
          .map((e) => e.value)
          .map((e) => weaponsGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
    else {
      return playerNameMapEntries
          .map((e) => e.value)
          .map((e) => charactersGameState[currentEntity]![e]!.contains(ConstantUtils.cross))
          .reduce((value, element) => value && element);
    }
  }

  /// Returns false if screen is hidden
  bool anyPlayerHasThisCardOrCardIsPublicInfo(EntityType entityType, String currentEntity) {
    if (isScreenHidden) {
      return false;
    }

    if (entityType == EntityType.Room) {
      return playerNameMapEntries
          .map((e) => e.value)
          .map((e) {
            final markings = roomsGameState[currentEntity]![e]!;
            return markings.contains(ConstantUtils.tick) || markings.contains(ConstantUtils.noOneHasThis);
      })
      .reduce((value, element) => value || element);
    }
    else if (entityType == EntityType.Weapon) {
      return playerNameMapEntries
          .map((e) => e.value)
          .map((e) {
        final markings = weaponsGameState[currentEntity]![e]!;
        return markings.contains(ConstantUtils.tick) || markings.contains(ConstantUtils.noOneHasThis);
      })
          .reduce((value, element) => value || element);
    }
    else {
      return playerNameMapEntries
          .map((e) => e.value)
          .map((e) {
        final markings = charactersGameState[currentEntity]![e]!;
        return markings.contains(ConstantUtils.tick) || markings.contains(ConstantUtils.noOneHasThis);
      })
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
            backgroundColor: MaterialStateProperty.all<Color>(primaryColorSettingState),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
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
                  title: Text("Edit game name", style: TextStyle(color: primaryColorSettingState),),
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
                      decoration: InputDecoration(
                        // hintText: playerNamesHint[index],
                        // hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryColorSettingState,
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
        editedGameNameValue = null;
      }
    });
  }

  _showEditPlayerNameDialog(String currentPlayerName) {
    _dismissDialogButton() {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(primaryColorSettingState),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: SizedBox(
            height: ScreenUtils.getScreenHeight(context) / 2.5,
            child: IntrinsicHeight(
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
                    title: Text("Edit player name", style: TextStyle(color: primaryColorSettingState),),
                  ),
                  body: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(ConstantUtils.maxPlayerNameCharacters),
                            ],
                            onChanged: (text) {
                              editedPlayerNameValue = text.trim();
                            },
                            initialValue: currentPlayerName.split(ConstantUtils.UNIQUE_NAME_DELIMITER).firstOrNull ?? "",
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              // hintText: playerNamesHint[index],
                              // hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: primaryColorSettingState,
                                ),
                              ),
                            ),
                          ),
                        ),
                        WidgetUtils.spacer(10),
                        Center(
                          child: Text(
                            "Please note that changing a player name will reset the undo/redo stack",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryColorSettingState,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        WidgetUtils.spacer(10),
                      ],
                    ),
                  )
              ),
            ),
          )
      );
    }).then((value) {
      if (editedPlayerNameValue != null) {
        _updatePlayerName(editedPlayerNameValue!, currentPlayerName, currentPlayerNameId);
        editedPlayerNameValue = null;
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
          lastSaved: gameDefinitionState.lastSaved,
          publicInfoCards: gameDefinitionState.publicInfoCards,
      );
    });

    _mainGameBloc.add(
        GameNameChanged(initialGame: gameDefinitionState)
    );

    // _mainGameBloc.add(
    //     MainGameStateChanged(
    //       initialGame: gameDefinitionState,
    //       charactersGameState: charactersGameState,
    //       weaponsGameState: weaponsGameState,
    //       roomsGameState: roomsGameState,
    //       gameBackgroundColorState: cellBackgroundColourState,
    //       undoStack: undoStack,
    //       undoStackPlayerNameMap: undoStackPlayerNameMap,
    //       redoStack: redoStack,
    //       redoStackPlayerNameMap: redoStackPlayerNameMap,
    //     )
    // );
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

        final currentCellBackgroundMap = cellBackgroundColourState[currentCharacter]!;
        currentCellBackgroundMap[newPlayerNamePlusId] = cellBackgroundColourState[currentCharacter]![originalPlayerNamePlusId]!;
        currentCellBackgroundMap.remove(originalPlayerNamePlusId);
        cellBackgroundColourState[currentCharacter] = currentCellBackgroundMap;
      });

      ConstantUtils.weaponList.forEach((currentWeapon) {
        final currentMarkingMap = weaponsGameState[currentWeapon]!;
        currentMarkingMap[newPlayerNamePlusId] = weaponsGameState[currentWeapon]![originalPlayerNamePlusId]!;
        currentMarkingMap.remove(originalPlayerNamePlusId);
        weaponsGameState[currentWeapon] = currentMarkingMap;

        final currentCellBackgroundMap = cellBackgroundColourState[currentWeapon]!;
        currentCellBackgroundMap[newPlayerNamePlusId] = cellBackgroundColourState[currentWeapon]![originalPlayerNamePlusId]!;
        currentCellBackgroundMap.remove(originalPlayerNamePlusId);
        cellBackgroundColourState[currentWeapon] = currentCellBackgroundMap;
      });

      ConstantUtils.roomList.forEach((currentRoom) {
        final currentMarkingMap = roomsGameState[currentRoom]!;
        currentMarkingMap[newPlayerNamePlusId] = roomsGameState[currentRoom]![originalPlayerNamePlusId]!;
        currentMarkingMap.remove(originalPlayerNamePlusId);
        roomsGameState[currentRoom] = currentMarkingMap;

        final currentCellBackgroundMap = cellBackgroundColourState[currentRoom]!;
        currentCellBackgroundMap[newPlayerNamePlusId] = cellBackgroundColourState[currentRoom]![originalPlayerNamePlusId]!;
        currentCellBackgroundMap.remove(originalPlayerNamePlusId);
        cellBackgroundColourState[currentRoom] = currentCellBackgroundMap;
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
          lastSaved: gameDefinitionState.lastSaved,
          publicInfoCards: gameDefinitionState.publicInfoCards,
      );
    });

    _mainGameBloc.add(
        PlayerNameChanged(initialGame: gameDefinitionState)
    );

    // _mainGameBloc.add(
    //     MainGameStateChanged(
    //       initialGame: gameDefinitionState,
    //       charactersGameState: charactersGameState,
    //       weaponsGameState: weaponsGameState,
    //       roomsGameState: roomsGameState,
    //       gameBackgroundColorState: cellBackgroundColourState,
    //       undoStack: undoStack,
    //       redoStack: redoStack,
    //     )
    // );

  }

  _addNextQuickMarker(EntityType entityType, String currentEntity, String currentPlayerName) {
    if (currentQuickMarkerIndex < ConstantUtils.quickMarkers.length - 1) {
      currentQuickMarkerIndex = currentQuickMarkerIndex + 1;
    }
    else {
      currentQuickMarkerIndex = 0;
    }
    final nextMarker = ConstantUtils.quickMarkers[currentQuickMarkerIndex];

    final markersToRemove = ConstantUtils.quickMarkers.where((element) => element != nextMarker);
    setState(() {
      if (entityType == EntityType.Character) {
        charactersGameState[currentEntity]?[currentPlayerName]?.remove(nextMarker);
        markersToRemove.forEach((element) {
          charactersGameState[currentEntity]?[currentPlayerName]?.remove(element);
        });
      }
      else if (entityType == EntityType.Weapon) {
        weaponsGameState[currentEntity]?[currentPlayerName]?.remove(nextMarker);
        markersToRemove.forEach((element) {
          weaponsGameState[currentEntity]?[currentPlayerName]?.remove(element);
        });
      }
      else {
        roomsGameState[currentEntity]?[currentPlayerName]?.remove(nextMarker);
        markersToRemove.forEach((element) {
          roomsGameState[currentEntity]?[currentPlayerName]?.remove(element);
        });
      }
      selectedMarkingsFromDialog.add(nextMarker);
    });
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
                      onDoubleTap: () {
                        setState(() {
                          _addNextQuickMarker(EntityType.Room, currentEntity, currentPlayerName);
                        });
                        _markDialogAsClosedAndSaveMarking(EntityType.Room, currentEntity, currentPlayerName);
                      },
                      onTap: () {
                        final List<String> currentMarkings = List.from(roomsGameState[currentEntity]![currentPlayerName]!);
                        // Only show dialog select if not an initial card from GameDefinition
                        if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                            !roomsGameState[currentEntity]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick) &&
                            !roomsGameState[currentEntity]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.noOneHasThis)
                        ) {
                          _showMarkerSelectDialog(EntityType.Room, currentEntity, currentPlayerName, currentMarkings);
                        }
                        else {
                          if (!isSnackbarBeingShown) {
                            isSnackbarBeingShown = true;
                            SnackbarUtils.showSnackBarMedium(context, "Cannot modify markings here as this is initial game info! Long press to change background colour if needed.");

                            if (debounce?.isActive ?? false) debounce?.cancel();
                            debounce = Timer(SnackbarUtils.mediumDuration, () {
                              isSnackbarBeingShown = false;
                            });
                          }


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
            child: const Center(
              child: Text(
                "Names",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
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
                  children: playerNameMapEntries.map((currentPlayerNameMap) {

                    final knownWeapons = weaponsGameState.entries.where((entry) {
                      return entry.value[currentPlayerNameMap.value]!.contains(ConstantUtils.tick);
                    });
                    final knownRooms = roomsGameState.entries.where((entry) {
                      return entry.value[currentPlayerNameMap.value]!.contains(ConstantUtils.tick);
                    });
                    final knownCharacters = charactersGameState.entries.where((entry) {
                      return entry.value[currentPlayerNameMap.value]!.contains(ConstantUtils.tick);
                    });
                    final knownCards = knownCharacters.length + knownRooms.length + knownWeapons.length;

                    return [
                      Expanded(
                        flex:  3,
                        child: InkWell(
                          key: currentPlayerNameMap.key == 0 ? playerNameTextKey : null,
                          onTap: () {
                            _showEditPlayerNameDialog(currentPlayerNameMap.value);
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
                                      currentPlayerNameMap.value.split(ConstantUtils.UNIQUE_NAME_DELIMITER).firstOrNull ?? "",
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
                                child: WidgetUtils.spacer(2)
                              ),
                              Container(
                                color: Colors.grey.shade200,
                                height: 17.5,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Visibility(
                                    visible: !isScreenHidden,
                                    child: CircleAvatar(
                                      backgroundColor: knownCards == 0 ? Colors.red : (knownCards == maxCardsPerPlayer ? Colors.teal : Colors.orange) ,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Center(
                                          child: Text(
                                            "${knownCards}/${maxCardsPerPlayer}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                              color: Colors.white
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                  color: Colors.grey.shade200,
                                  width: double.infinity,
                                  child: WidgetUtils.spacer(2)
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
                      onDoubleTap: () {
                        setState(() {
                          _addNextQuickMarker(EntityType.Weapon, currentEntity, currentPlayerName);
                        });
                        _markDialogAsClosedAndSaveMarking(EntityType.Weapon, currentEntity, currentPlayerName);
                      },
                      onTap: () {
                        final List<String> currentMarkings = List.from(weaponsGameState[currentEntity]![currentPlayerName]!);
                        if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                            !weaponsGameState[currentEntity]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick) &&
                            !weaponsGameState[currentEntity]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.noOneHasThis)
                        ) {
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
                            _showBackgroundColourSelectDialog(EntityType.Character, currentCharacter, currentPlayerName, currentSelectedColor);
                          },
                          onDoubleTap: () {
                            setState(() {
                              _addNextQuickMarker(EntityType.Character, currentCharacter, currentPlayerName);
                            });
                            _markDialogAsClosedAndSaveMarking(EntityType.Character, currentCharacter, currentPlayerName);
                          },
                          onTap: () {
                            final List<String> currentMarkings = List.from(charactersGameState[currentCharacter]![currentPlayerName]!);
                            // Check if we are not changing anything from initiral state
                            if (!(currentPlayerName == gameDefinitionState.playerNames[0]!) &&
                                !charactersGameState[currentCharacter]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.tick) &&
                                !charactersGameState[currentCharacter]![gameDefinitionState.playerNames[0]!]!.contains(ConstantUtils.noOneHasThis)
                            ) {
                              _showMarkerSelectDialog(EntityType.Character, currentCharacter, currentPlayerName, currentMarkings);
                            }
                            else {
                              SnackbarUtils.showSnackBarMedium(context, "Cannot modify markings here as this is initial game info! Long press to change background colour if needed.");
                            }
                          },
                          child: Card(
                            key: index == 1 && currentCharacter == ConstantUtils.characterList[0] ? cell1Key :
                                (index == 1 && currentCharacter == ConstantUtils.characterList[1] ? cell2Key :
                                (index == 1 && currentCharacter == ConstantUtils.characterList[2] ? cell3Key : null)),
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
    if ((charactersGameState[currentCharacter]?[playerName]?.isNotEmpty ?? false) && !isScreenHidden) {
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
                else if (marking == ConstantUtils.noOneHasThis) {
                  return _maybeMarker2IconNoOneHasThis(marking, () {
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
    if ((roomsGameState[currentRoom]?[playerName]?.isNotEmpty ?? false) && !isScreenHidden) {
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
            else if (marking == ConstantUtils.noOneHasThis) {
              return _maybeMarker2IconNoOneHasThis(marking, () {
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
    if ((weaponsGameState[currentWeapon]?[playerName]?.isNotEmpty ?? false) && !isScreenHidden) {
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
            else if (marking == ConstantUtils.noOneHasThis) {
              return _maybeMarker2IconNoOneHasThis(marking, () {
                weaponsGameState[currentWeapon]![playerName] =
                List.from(charactersGameState[currentWeapon]?[playerName] ?? [])..remove(marking);
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
    return VerticalDivider(
      width: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT / 2,
      thickness: 5,
      // indent: 20,
      // endIndent: 0,
      color: primaryColorSettingState,
    );
  }

  Widget _verticalDivider2() {
    return VerticalDivider(
      width: 2,
      thickness: 2.5,
      // indent: 20,
      // endIndent: 0,
      color: primaryColorSettingState,
    );
  }

  _divider() {
    return Divider(
      height: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT.toDouble(),
      thickness: 5,
      endIndent: 0,
      color: primaryColorSettingState,
    );
  }


  _divider2() {
    return Divider(
      height: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT.toDouble(),
      thickness: 2.5,
      endIndent: 0,
      color: primaryColorSettingState,
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
        style: TextStyle(
            color: primaryColorSettingState,
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
      selectedMarkingsFromDialog = [];
    });
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
      if (!dontAskAgainForInferenceThisPlayerHasNoOtherCards) {
        _showInferenceConfirmationDialog(
            InferenceType.ThisPlayerHasNoOtherCards,
            entityType,
            currentEntity,
            currentPlayerName,
            _inferNoOtherRemainingCardsToDiscoverForCurrentPlayerConfirmationText(currentPlayerName, currentEntity),
                () {
              _markAllOtherCardsForCurrentPlayerAsNotHaving(entityType, currentPlayerName, currentEntity);
              Future.delayed(const Duration(milliseconds: 100), () {
                _inferAndConfirmInferenceIfNeededMaxCardsKnownForEntityType(entityType, currentPlayerName, currentEntity);  
              });
            }
        );
      }
      else {
        _markAllOtherCardsForCurrentPlayerAsNotHaving(entityType, currentPlayerName, currentEntity);
        Future.delayed(const Duration(milliseconds: 100), () {
          _inferAndConfirmInferenceIfNeededMaxCardsKnownForEntityType(entityType, currentPlayerName, currentEntity);
        });
      }
    }
    else {
      // We skip to the third and final inference, if possible
      _inferAndConfirmInferenceIfNeededMaxCardsKnownForEntityType(entityType, currentPlayerName, currentEntity);
    }
  }

  _inferAndConfirmInferenceIfNeededMaxCardsKnownForEntityType(
      EntityType entityType,
      String currentPlayerName,
      String currentEntity,
      ) {

    askAndInferDetails(String unknownCardName) {
      if (!dontAskAgainForInferenceMaxCardsKnownForEntityType) {
        _showInferenceConfirmationDialog(
            InferenceType.MaxCardsKnownForEntityType,
            entityType,
            currentEntity,
            currentPlayerName,
            _inferMaxCardsKnownForEntityTypeConfirmationText(currentPlayerName, currentEntity, entityType),
                () {
              _markEntityAsNoPlayerHaving(entityType, unknownCardName);
            }
        );
      }
      else {
        _markEntityAsNoPlayerHaving(entityType, unknownCardName);
      }
    }

    final int numberOfKnownCards;
    final String? unknownCardName;
    if (entityType == EntityType.Character) {
      final allMarkingsForCharacters = charactersGameState.map((key, value) {
        return MapEntry(key, value.entries.map((e) => e.value).expand((element) => element));
      });
      numberOfKnownCards = allMarkingsForCharacters.entries.where((entry) {
        return entry.value.contains(ConstantUtils.tick) || entry.value.contains(ConstantUtils.noOneHasThis);
      }).length;
      unknownCardName = allMarkingsForCharacters.entries.where((entry) {
        return !(entry.value.contains(ConstantUtils.tick) || entry.value.contains(ConstantUtils.noOneHasThis));
      }).map((e) => e.key).firstOrNull;

      if (numberOfKnownCards == ConstantUtils.characterList.length - 1) {
        askAndInferDetails(unknownCardName!);
      }
    }
    else if (entityType == EntityType.Weapon) {
      final allMarkingsForWeapons = weaponsGameState.map((key, value) {
        return MapEntry(key, value.entries.map((e) => e.value).expand((element) => element));
      });
      numberOfKnownCards = allMarkingsForWeapons.entries.where((entry) {
        return entry.value.contains(ConstantUtils.tick) || entry.value.contains(ConstantUtils.noOneHasThis);
      }).length;
      unknownCardName = allMarkingsForWeapons.entries.where((entry) {
        return !(entry.value.contains(ConstantUtils.tick) || entry.value.contains(ConstantUtils.noOneHasThis));
      }).map((e) => e.key).firstOrNull;

      if (numberOfKnownCards == ConstantUtils.weaponList.length - 1) {
        askAndInferDetails(unknownCardName!);
      }
    }
    else {
      final allMarkingsForRooms = roomsGameState.map((key, value) {
        return MapEntry(key, value.entries.map((e) => e.value).expand((element) => element));
      });
      numberOfKnownCards = allMarkingsForRooms.entries.where((entry) {
        return entry.value.contains(ConstantUtils.tick) || entry.value.contains(ConstantUtils.noOneHasThis);
      }).length;
      unknownCardName = allMarkingsForRooms.entries.where((entry) {
        return !(entry.value.contains(ConstantUtils.tick) || entry.value.contains(ConstantUtils.noOneHasThis));
      }).map((e) => e.key).firstOrNull;

      if (numberOfKnownCards == ConstantUtils.roomList.length - 1) {
        askAndInferDetails(unknownCardName!);
      }
    }
  }

  _markCellBackgroundColourDialogDialogAsClosedAndSaveBackgoundColour(EntityType entityType, String currentEntity, String currentPlayerName) {
    if (selectedBackgroundColourFromDialog != null) {
      KeyboardUtils.mediumImpact();
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

  /// Marks every player as NOT having the following entity
  /// If there is tick or cross already on it, it is untouched
  /// Otherwise a cross is added to markings list
  _markEntityAsNoPlayerHaving(EntityType entityType, String currentEntity) {
    if (entityType == EntityType.Character) {
      GameState temp = {};
      charactersGameState.forEach((characterName, playerNameMarkingMap) {
        if (currentEntity == characterName) {
          final newMap = playerNameMarkingMap.map((playerName, markings) {
            return MapEntry(
                playerName,
                !(markings.contains(ConstantUtils.cross)) ? [...markings, ConstantUtils.cross] : markings
            );
          });
          temp[characterName] = newMap;
        }
        else {
          temp[characterName] = playerNameMarkingMap;
        }
      });

      setState(() {
        charactersGameState = temp;
      });
      _updateBlocStateFromState();
    }
    else if (entityType == EntityType.Weapon) {
      GameState temp = {};
      weaponsGameState.forEach((weaponName, playerNameMarkingMap) {
        if (currentEntity == weaponName) {
          final newMap = playerNameMarkingMap.map((playerName, markings) {
            return MapEntry(
                playerName,
                !(markings.contains(ConstantUtils.cross)) ? [...markings, ConstantUtils.cross] : markings
            );
          });
          temp[weaponName] = newMap;
        }
        else {
          temp[weaponName] = playerNameMarkingMap;
        }
      });
      setState(() {
        weaponsGameState = temp;
      });
      _updateBlocStateFromState();
    }
    else {
      GameState temp = {};
      roomsGameState.forEach((roomName, playerNameMarkingMap) {
        if (currentEntity == roomName) {
          final newMap = playerNameMarkingMap.map((playerName, markings) {
            return MapEntry(
                playerName,
                !(markings.contains(ConstantUtils.cross)) ? [...markings, ConstantUtils.cross] : markings
            );
          });
          temp[roomName] = newMap;
        }
        else {
          temp[roomName] = playerNameMarkingMap;
        }
      });
      setState(() {
        roomsGameState = temp;
      });
      _updateBlocStateFromState();
    }

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
            style: TextStyle(
                color: primaryColorSettingState,
                fontSize: 16
            ),
            children: [
              TextSpan(
                  text: _refinedPlayerName(currentPlayerName),
                  style: TextStyle(
                      color: primaryColorSettingState,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: " has the ",
                  style: TextStyle(
                    color: primaryColorSettingState,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: cardDisplayNameMap[currentEntity],
                  style: TextStyle(
                      color: primaryColorSettingState,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: " card, we infer that no other player has it!\n\nHit confirm if you'd like to mark all other players as not having this card.",
                  style: TextStyle(
                    color: primaryColorSettingState,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
            ]
        )
    );
  }

  _inferMaxCardsKnownForEntityTypeConfirmationText(String currentPlayerName, String currentEntity, EntityType entityType) {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: "Since you have confirmed that ",
            style: TextStyle(
                color: primaryColorSettingState,
                fontSize: 16
            ),
            children: [
              TextSpan(
                  text: _refinedPlayerName(currentPlayerName),
                  style: TextStyle(
                      color: primaryColorSettingState,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: " has the ",
                  style: TextStyle(
                    color: primaryColorSettingState,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: cardDisplayNameMap[currentEntity],
                  style: TextStyle(
                      color: primaryColorSettingState,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: " card, we now know all the possible ${entityType.name.toLowerCase()}s!\n\nHit confirm if you'd like to mark the remaining ${entityType.name.toLowerCase()} as missing.",
                  style: TextStyle(
                    color: primaryColorSettingState,
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
            style: TextStyle(
                color: primaryColorSettingState,
                fontSize: 16
            ),
            children: [
              TextSpan(
                  text: _refinedPlayerName(currentPlayerName),
                  style: TextStyle(
                      color: primaryColorSettingState,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: " has the ",
                  style: TextStyle(
                    color: primaryColorSettingState,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: cardDisplayNameMap[currentEntity],
                  style: TextStyle(
                      color: primaryColorSettingState,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              TextSpan(
                  text: " card, we now know all the cards they posses!\n\nHit confirm if you'd like to mark all other cards for this player as missing.",
                  style: TextStyle(
                    color: primaryColorSettingState,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                  )
              ),
            ]
        )
    );
  }

  _markDialogAsClosedAndSaveMarking(EntityType entityType, String currentEntity, String currentPlayerName) {
    if (selectedMarkingsFromDialog.isNotEmpty) {
      KeyboardUtils.mediumImpact();

      // Something was selected, persist it
      selectedMarkingsFromDialog.forEach((selectedMarkingFromDialog) {
        if (entityType == EntityType.Character) {
          if (selectedMarkingFromDialog == ConstantUtils.tick) {
            if (charactersGameState[currentEntity]?[currentPlayerName]?.contains(selectedMarkingFromDialog) ?? false) {
              // do nothing as we are removing
            }
            else {
              // We are adding a Tick over here. Ask user for confirmation to infer
              if (!dontAskAgainForInferenceNoOtherPlayerHasThisCard) {
                _showInferenceConfirmationDialog(
                    InferenceType.NoOtherPlayerHasThisCard,
                    entityType,
                    currentEntity,
                    currentPlayerName,
                    _inferNoOtherPlayerHasThisCardConfirmationText(currentPlayerName, currentEntity),
                        () {
                      _markAllOtherPlayersAsNotHavingCharacterCard(currentPlayerName, currentEntity);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
                      });
                    }
                );
              }
              else {
                _markAllOtherPlayersAsNotHavingCharacterCard(currentPlayerName, currentEntity);
                Future.delayed(const Duration(milliseconds: 100), () {
                  _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
                });
              }
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
            charactersGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog);
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
              if (!dontAskAgainForInferenceNoOtherPlayerHasThisCard) {
                _showInferenceConfirmationDialog(
                    InferenceType.NoOtherPlayerHasThisCard,
                    entityType,
                    currentEntity,
                    currentPlayerName,
                    _inferNoOtherPlayerHasThisCardConfirmationText(currentPlayerName, currentEntity),
                        () {
                      _markAllOtherPlayersAsNotHavingWeaponCard(currentPlayerName, currentEntity);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
                      });
                    }
                );
              }
              else {
                _markAllOtherPlayersAsNotHavingWeaponCard(currentPlayerName, currentEntity);
                Future.delayed(const Duration(milliseconds: 100), () {
                  _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
                });
              }
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
            weaponsGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog);
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
              if (!dontAskAgainForInferenceNoOtherPlayerHasThisCard) {
                _showInferenceConfirmationDialog(
                    InferenceType.NoOtherPlayerHasThisCard,
                    entityType,
                    currentEntity,
                    currentPlayerName,
                    _inferNoOtherPlayerHasThisCardConfirmationText(currentPlayerName, currentEntity),
                        () {
                      _markAllOtherPlayersAsNotHavingRoomCard(currentPlayerName, currentEntity);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
                      });
                    }
                );
              }
              else {
                _markAllOtherPlayersAsNotHavingRoomCard(currentPlayerName, currentEntity);
                Future.delayed(const Duration(milliseconds: 100), () {
                  _inferAndConfirmInferenceIfNeededRemainingCardsForCurrentPlayer(entityType, currentPlayerName, currentEntity);
                });
              }
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
            roomsGameState[currentEntity]?[currentPlayerName]?.add(selectedMarkingFromDialog);
          }
          // }
        }
      });

      _updateBlocStateFromState();
      setState(() {
        isMarkingDialogOpen = false;
        selectedMarkingsFromDialog = [];
      });
    }
  }

  _updateBlocStateFromState() {
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

  _showGameOverDialog(GameConclusion conclusion) {
    _dismissDialogButton() {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(primaryColorSettingState),
          ),
          onPressed: () async {
            // widget.closeDialogCallback(widget.entityType, widget.currentEntity, widget.currentPlayerName);
            Navigator.pop(context, false);
          },
          child: const Text("Go back", style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      );
    }

    showDialog(context: context, builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
              child: Text(
                "Game Over",
                style: TextStyle(color: widget.gameSettings.primaryColorSetting),
              ),
            ),
            iconTheme: IconThemeData(
              color: widget.gameSettings.primaryColorSetting,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _divider(),
                WidgetUtils.spacer(25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Congratulations!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColorSettingState,
                      ),
                    ),
                  ),
                ),
                WidgetUtils.spacer(25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "With the info you have noted down, we can now infer the unknown cards!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      color: primaryColorSettingState,
                      fontSize: 18,
                    ),
                  ),
                ),
                WidgetUtils.spacer(10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "We can now deduce that ",
                        style: TextStyle(
                            color: primaryColorSettingState,
                            fontSize: 18
                        ),
                        children: [
                          TextSpan(
                              text: cardDisplayNameMap[conclusion.character],
                              style: TextStyle(
                                  color: primaryColorSettingState,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                          TextSpan(
                              text: " committed the crime in the ",
                              style: TextStyle(
                                color: primaryColorSettingState,
                                fontSize: 18,
                                // fontWeight: FontWeight.bold
                              )
                          ),
                          TextSpan(
                              text: cardDisplayNameMap[conclusion.room],
                              style: TextStyle(
                                  color: primaryColorSettingState,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                          TextSpan(
                              text: " using the ",
                              style: TextStyle(
                                color: primaryColorSettingState,
                                fontSize: 18,
                                // fontWeight: FontWeight.bold
                              )
                          ),
                          TextSpan(
                              text: cardDisplayNameMap[conclusion.weapon],
                              style: TextStyle(
                                  color: primaryColorSettingState,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                        ]
                    )
                  ),
                ),
                WidgetUtils.spacer(10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "On your next turn, you can guess your conclusion and win the game!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      color: primaryColorSettingState,
                      fontSize: 18,
                    ),
                  ),
                ),
                WidgetUtils.spacer(25),
                _divider(),
              ],
            ),
          ),
          bottomNavigationBar: Row(
            children: [
              Expanded(
                child: _dismissDialogButton(),
              ),
            ],
          ),
        ),
      );
    });
  }

  _showMarkerSelectDialog(
      EntityType entityType,
      String currentEntity,
      String currentPlayerName,
      List<String> currentMarkings
      ) {
    KeyboardUtils.mediumImpact();

    setState(() {
      isMarkingDialogOpen = true;
    });

    showDialog<bool>(context: context, builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(
                      color: primaryColorSettingState,
                      width: 1
                  )
              ),
              child: MarkingsView(
                  primaryColorSetting: primaryColorSettingState,
                  selectMultipleMarkingsAtOnceSetting: selectMultipleMarkingsAtOnceSettingState,
                  currentMarkings: currentMarkings,
                  entityType: entityType,
                  currentEntity: currentEntity,
                  currentPlayerName: currentPlayerName,
                  // closeDialogCallback: _markDialogAsClosedAndSaveMarking,
                  setStateAndPopIfNeededCallback: _setStateAndPopIfNeeded,
                  closeDialogAndResetCellCallback: _markDialogAsClosedAndResetMarking,
              ),
            );
          },
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
            backgroundColor: MaterialStateProperty.all<Color>(primaryColorSettingState),
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
            backgroundColor: MaterialStateProperty.all<Color>(primaryColorSettingState),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child:  SizedBox(
          height: ScreenUtils.getScreenHeight(context) / 2,
          child: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: Text(
                          "Select the colour you want to change the cell background to",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: primaryColorSettingState
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
                              Expanded(
                                  child: Text(
                                    "Current selection",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: primaryColorSettingState,
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
      InferenceType inferenceType,
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
            backgroundColor: MaterialStateProperty.all<Color>(primaryColorSettingState),
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
            backgroundColor: MaterialStateProperty.all<Color>(primaryColorSettingState),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child:  SizedBox(
            height: ScreenUtils.getScreenHeight(context) / 2,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Center(child: Text("Confirm Inference", style: TextStyle(color: primaryColorSettingState),)),
                iconTheme: IconThemeData(
                  color: primaryColorSettingState,
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
                      Row(
                        children: [
                          StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return Checkbox(
                                fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                  final c = primaryColorSettingState;
                                  if (states.contains(MaterialState.disabled)) {
                                    return c.withOpacity(.32);
                                  }
                                  return c;
                                }),
                                value: inferenceType == InferenceType.NoOtherPlayerHasThisCard ?
                                dontAskAgainForInferenceNoOtherPlayerHasThisCard :
                                (inferenceType == InferenceType.ThisPlayerHasNoOtherCards ? dontAskAgainForInferenceThisPlayerHasNoOtherCards : dontAskAgainForInferenceMaxCardsKnownForEntityType),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      if (inferenceType == InferenceType.NoOtherPlayerHasThisCard) {
                                        dontAskAgainForInferenceNoOtherPlayerHasThisCard = value;
                                      }
                                      else if (inferenceType == InferenceType.MaxCardsKnownForEntityType) {
                                        dontAskAgainForInferenceMaxCardsKnownForEntityType = value;
                                      }
                                      else {
                                        dontAskAgainForInferenceThisPlayerHasNoOtherCards = value;
                                      }
                                    });
                                  }
                                });
                            }
                          ),
                          WidgetUtils.spacer(5),
                          Text(
                            "Do not ask again",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColorSettingState
                            ),
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

  _setStateAndPopIfNeeded(
      String text,
      EntityType entityType,
      String currentEntity,
      String currentPlayerName,
  ) {
    setState(() {
      selectedMarkingsFromDialog.add(text);

      roomsGameState = roomsGameState;
      charactersGameState = charactersGameState;
      weaponsGameState = weaponsGameState;

    });

    if (!selectMultipleMarkingsAtOnceSettingState) {
      Navigator.pop(context);
    }
  }

  _setBackgroundColourStateAndPop(Color selectedColor, BuildContext context) {
    setState(() {
      selectedBackgroundColourFromDialog = selectedColor;
    });
    Navigator.pop(context);
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
                color: isSelectedAlready ? primaryColorSettingState : Colors.transparent,
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: primaryColorSettingState
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
          backgroundColor: Colors.teal,
          child: Center(child: Icon(Icons.check, color: Colors.white, size: ConstantUtils.MARKING_ICON_DIAMETER,)),
        )
    );
  }

  Widget _maybeMarker2IconCross(String text, VoidCallback onTap) {
    return const SizedBox(
        width: ConstantUtils.MARKING_DIAMETER,
        height: ConstantUtils.MARKING_DIAMETER,
        child: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Center(child: Icon(Icons.close, size: ConstantUtils.MARKING_ICON_DIAMETER, color: Colors.white,)),
        )
    );
  }

  Widget _maybeMarker2IconWarn(String text, VoidCallback onTap) {
    return const SizedBox(
        width: ConstantUtils.MARKING_DIAMETER,
        height: ConstantUtils.MARKING_DIAMETER,
        child: CircleAvatar(
          backgroundColor: Colors.amber,
          child: Center(child: Icon(Icons.warning, size: ConstantUtils.MARKING_ICON_DIAMETER, color: Colors.white,)),
        )
    );
  }

  Widget _maybeMarker2IconNoOneHasThis(String text, VoidCallback onTap) {
    return SizedBox(
        width: ConstantUtils.MARKING_DIAMETER,
        height: ConstantUtils.MARKING_DIAMETER,
        child: CircleAvatar(
          backgroundColor: primaryColorSettingState,
          child: const Center(child: Icon(Icons.not_interested, size: ConstantUtils.MARKING_ICON_DIAMETER, color: Colors.white,)),
        )
    );
  }

}