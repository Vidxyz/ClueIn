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

  const AddBasicGameDetailsView({super.key});


  @override
  State<StatefulWidget> createState() {
    return AddBasicGameDetailsViewState();
  }
}

class AddBasicGameDetailsViewState extends State<AddBasicGameDetailsView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<String> playerNamesHint = ["P1", "P2", "P3", "P4", "P5", "P6"];

  final TextEditingController _totalPlayersController = TextEditingController();
  int totalPlayerCountState = 6;

  late CreateNewGameBloc _createNewGameBloc;

  @override
  void initState() {
    super.initState();

    _createNewGameBloc = BlocProvider.of<CreateNewGameBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return  BlocListener<CreateNewGameBloc, CreateNewGameState>(
      listener: (context, state) {

      },
      child: BlocBuilder<CreateNewGameBloc, CreateNewGameState>(
        builder: (context, state) {
          if (state is NewGameDetailsModified) {
            return SingleChildScrollView(
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
                      const Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "You are P1",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ConstantUtils.primaryAppColor,
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
            );
          }
          else {
            return WidgetUtils.progressIndicator();
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
                          color: index == 0 ? ConstantUtils.primaryAppColor : null,
                        ),
                      ),
                    )
                ),
                Expanded(
                    flex: 7,
                    child: Column(
                      children: WidgetUtils.skipNulls([
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(5),
                            ],
                          onChanged: (text) {
                            final currentState = _createNewGameBloc.state;
                            if (currentState is NewGameDetailsModified) {
                              Map<int, String> newList = Map.from(currentState.playerNames);
                              newList[index] = text.trim();
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
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ConstantUtils.primaryAppColor,
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
            onChanged: (text) {
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter game name',
              hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ),
        )
      ],
    );
  }
}