import 'dart:math';

import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/keyboard_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_bloc.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_event.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';

class AddBasicGameDetailsView extends StatefulWidget {
  final Color primaryAppColorFromSetting;
  final int numberOfPreviouslySavedGames;
  
  const AddBasicGameDetailsView({super.key,
    required this.primaryAppColorFromSetting,
    required this.numberOfPreviouslySavedGames,
  });


  @override
  State<StatefulWidget> createState() {
    return AddBasicGameDetailsViewState();
  }
}

class AddBasicGameDetailsViewState extends State<AddBasicGameDetailsView> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver  {
  @override
  bool get wantKeepAlive => true;

  final List<String> playerNamesHint = ["Me", "P2", "P3", "P4", "P5", "P6"];

  int totalPlayerCountState = 6;

  late CreateNewGameBloc _createNewGameBloc;

  TextEditingController gameNameController = TextEditingController();

  List<TextEditingController> playerNameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool shouldGameNameBeReset = true;
  bool shouldPlayerNamesBeReset = true;

  @override
  void initState() {
    super.initState();

    _createNewGameBloc = BlocProvider.of<CreateNewGameBloc>(context);

    if (shouldGameNameBeReset) {
      gameNameController.text = "Game ${widget.numberOfPreviouslySavedGames + 1}";
      shouldGameNameBeReset = false;
    }

    if (shouldPlayerNamesBeReset) {
      playerNameControllers.asMap().entries.forEach((element) {
        playerNameControllers[element.key].text = playerNamesHint[element.key];
      });
      shouldPlayerNamesBeReset = false;
    }

    final currentState = _createNewGameBloc.state;
    if (currentState is NewGameDetailsModified) {
      _createNewGameBloc.add(
          NewGameDetailedChanged(
              gameName: gameNameController.text,
              totalPlayers: currentState.totalPlayers,
              playerNames: {
                0: playerNameControllers[0].text,
                1: playerNameControllers[1].text,
                2: playerNameControllers[2].text,
                3: playerNameControllers[3].text,
                4: playerNameControllers[4].text,
                5: playerNameControllers[5].text,
              },
              initialCards: currentState.initialCards
          )
      );
    }

  }

  @override
  void dispose() {
    super.dispose();
    gameNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  BlocListener<CreateNewGameBloc, CreateNewGameState>(
      listener: (context, state) {
        if (state is NewGameDetailsModified) {
          state.playerNames.entries.forEach((element) {
            playerNameControllers[element.key].text = element.value;
            playerNameControllers[element.key].selection = TextSelection.fromPosition(TextPosition(offset: element.value.length));
          });
        }
      },
      child: BlocBuilder<CreateNewGameBloc, CreateNewGameState>(
        builder: (context, state) {
          if (state is NewGameDetailsModified) {
            return ScrollConfiguration(
              behavior: const ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: widget.primaryAppColorFromSetting,
                child: SingleChildScrollView(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        KeyboardUtils.hideKeyboard(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: WidgetUtils.skipNulls([
                          Divider(color: Theme.of(context).primaryColor),
                          WidgetUtils.spacer(2.5),
                          _renderGameNameView(),
                          WidgetUtils.spacer(2.5),
                          _renderTotalPlayers(),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "You are P1",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: widget.primaryAppColorFromSetting,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          WidgetUtils.spacer(2.5),
                          _renderParticipantsList(state),
                          // Move this to its own widget
                          // _renderAvailabilitiesView(state),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          else {
            return WidgetUtils.progressIndicator(widget.primaryAppColorFromSetting);
          }
        }),
      );
  }

  _renderParticipantsList(NewGameDetailsModified state) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: totalPlayerCountState,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        "P${index + 1}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: index == 0 ? widget.primaryAppColorFromSetting : null,
                        ),
                      ),
                    )
                ),
                Expanded(
                    flex: 7,
                    child: Column(
                      children: WidgetUtils.skipNulls([
                        TextFormField(
                         controller: playerNameControllers[index],
                          textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(ConstantUtils.maxPlayerNameCharacters),
                            ],
                          onChanged: (text) {
                            final currentState = _createNewGameBloc.state;
                            if (currentState is NewGameDetailsModified) {
                              Map<int, String> newList = Map.from(currentState.playerNames);
                              newList[index] = text.trim().capitalize();
                              _createNewGameBloc.add(
                                  NewGameDetailedChanged(
                                      gameName: currentState.gameName,
                                      totalPlayers: currentState.totalPlayers,
                                      playerNames: newList,
                                      initialCards: currentState.initialCards
                                  )
                              );
                            }
                          },
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: playerNamesHint[index],
                            hintStyle: const TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: widget.primaryAppColorFromSetting, width: 2.0),
                            ),
                            focusedBorder:  OutlineInputBorder(
                              borderSide: BorderSide(color: widget.primaryAppColorFromSetting, width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.primaryAppColorFromSetting,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                playerNameControllers[index].clear();
                                final currentState = _createNewGameBloc.state;
                                if (currentState is NewGameDetailsModified) {
                                  Map<int, String> newList = Map.from(currentState.playerNames);
                                  newList[index] = "";
                                  _createNewGameBloc.add(
                                      NewGameDetailedChanged(
                                          gameName: currentState.gameName,
                                          totalPlayers: currentState.totalPlayers,
                                          playerNames: newList,
                                          initialCards: currentState.initialCards
                                      )
                                  );
                                }
                              },
                              icon: const SizedBox(
                                height: 25,
                                child: CircleAvatar(
                                  backgroundColor: Colors.redAccent,
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    )
                ),
              ],
            ),
          );
        }
    );
  }

  _renderTotalPlayers() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Expanded(
              flex: 5,
              child: Center(
                child: Text(
                  "Total Players",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
          ),
          Expanded(
              flex: 8,
              child: NumberPicker(
                selectedTextStyle: TextStyle(
                  color: widget.primaryAppColorFromSetting,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                value: totalPlayerCountState,
                minValue: 2,
                maxValue: 6,
                onChanged: (value) {
                  setState(() {
                    totalPlayerCountState = max(min(value, 6), 2);
                  });
                  final currentState = _createNewGameBloc.state;
                  if (currentState is NewGameDetailsModified) {
                    _createNewGameBloc.add(
                        NewGameDetailedChanged(
                            gameName: currentState.gameName,
                            totalPlayers: totalPlayerCountState,
                            playerNames: currentState.playerNames,
                            initialCards: currentState.initialCards
                        )
                    );
                  }
                },
              )
          ),
        ],
      ),
    );
  }

  _renderGameNameView() {
    return Column(
      children: [
        const Text("Game name", style: TextStyle(fontSize: 16),),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: TextField(
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            controller: gameNameController,
            onChanged: (text) {
              if (text.trim().isEmpty) {
                gameNameController.clear();
              }
              final currentState = _createNewGameBloc.state;
              if (currentState is NewGameDetailsModified) {
                _createNewGameBloc.add(
                    NewGameDetailedChanged(
                        gameName: text.trim(),
                        totalPlayers: currentState.totalPlayers,
                        playerNames: currentState.playerNames,
                        initialCards: currentState.initialCards
                    )
                );
              }
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.primaryAppColorFromSetting, width: 2.0),
              ),
              focusedBorder:  OutlineInputBorder(
                borderSide: BorderSide(color: widget.primaryAppColorFromSetting, width: 2.0),
              ),
              border: const OutlineInputBorder(),
              hintText: 'Enter game name',
              hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
              suffixIcon: IconButton(
                onPressed: () {
                  gameNameController.clear();
                  final currentState = _createNewGameBloc.state;
                  if (currentState is NewGameDetailsModified) {
                    _createNewGameBloc.add(
                        NewGameDetailedChanged(
                            gameName: "",
                            totalPlayers: currentState.totalPlayers,
                            playerNames: currentState.playerNames,
                            initialCards: currentState.initialCards
                        )
                    );
                  }
                },
                icon: const SizedBox(
                  height: 25,
                  child: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(
                        Icons.clear,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}