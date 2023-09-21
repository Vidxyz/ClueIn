import 'package:cluein_app/src/models/game_card.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/keyboard_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_bloc.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_event.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddInitialCardsView extends StatefulWidget {
  const AddInitialCardsView({
    super.key,
  });


  @override
  State<StatefulWidget> createState() {
    return AddInitialCardsViewState();
  }
}

class AddInitialCardsViewState extends State<AddInitialCardsView> with WidgetsBindingObserver {


  Map<String, bool> personNameToBoolMap = {};
  Map<String, bool> weaponNameToBoolMap = {};
  Map<String, bool> roomNameToBoolMap = {};

  bool isPersonSectionExpanded = true;
  bool isWeaponSectionExpanded = true;
  bool isRoomSectionExpanded = true;

  final TextEditingController nameTextFieldController = TextEditingController();
  final TextEditingController personCountTextFieldController = TextEditingController();

  late CreateNewGameBloc _createNewGameBloc;

  bool hasHintDialogBeenShown = false;

  @override
  void initState() {
    super.initState();

    _createNewGameBloc = BlocProvider.of<CreateNewGameBloc>(context);
    final currentState = _createNewGameBloc.state;
    if (currentState is NewGameDetailsModified) {
      setState(() {
        nameTextFieldController.text = currentState.gameName;
        personCountTextFieldController.text = currentState.totalPlayers.toString();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!hasHintDialogBeenShown) {
        _showHintDialogToSetupGame();
        hasHintDialogBeenShown = true;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateNewGameBloc, CreateNewGameState>(
      listener: (context, state) {
        if (state is NewGameDetailsModified) {
          setState(() {
            nameTextFieldController.text = state.gameName;
            personCountTextFieldController.text = state.totalPlayers.toString();
          });
        }
      },
      child: BlocBuilder<CreateNewGameBloc, CreateNewGameState>(
          builder: (context, state) {
            if (state is NewGameDetailsModified) {
              return SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: WidgetUtils.skipNulls([
                      Divider(color: Theme.of(context).primaryColor),
                      WidgetUtils.spacer(2.5),
                      _renderGameNameView(state),
                      WidgetUtils.spacer(2.5),
                      _renderTotalPlayers(state),
                      WidgetUtils.spacer(2.5),
                      _renderSelectNumberOfCardsHintText(),
                      WidgetUtils.spacer(2.5),
                      _renderAllPersonCards(),
                      WidgetUtils.spacer(2.5),
                      _renderAllWeaponsCards(),
                      WidgetUtils.spacer(2.5),
                      _renderAllRoomsCards(),
                    ]),
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

  _renderSelectNumberOfCardsHintText() {
    final currentState = _createNewGameBloc.state;
    if (currentState is NewGameDetailsModified) {
      final maxCards = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / currentState.totalPlayers).floor();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            "Please select exactly the $maxCards cards that you start the game with",
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.teal,
                fontSize: 14,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      );
    }
  }

  _renderAllPersonCards() {
    return Column(
      children: [
        ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            setState(() {
              isPersonSectionExpanded = !isExpanded;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      isPersonSectionExpanded = !isExpanded;
                    });
                  },
                  title: const Text(
                    "Persons",
                    style:  TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.grey
                    ),
                  ),
                );
              },
              body: _renderCharacters(),
              isExpanded: isPersonSectionExpanded,
            )
          ],
        ),
      ],
    );
  }

  _renderAllWeaponsCards() {
    return Column(
      children: [
        ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            setState(() {
              isWeaponSectionExpanded = !isExpanded;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      isWeaponSectionExpanded = !isExpanded;
                    });
                  },
                  title: const Text(
                    "Weapons",
                    style:  TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.grey
                    ),
                  ),
                );
              },
              body: _renderWeapons(),
              isExpanded: isWeaponSectionExpanded,
            )
          ],
        ),
      ],
    );
  }

  _renderAllRoomsCards() {
    return Column(
      children: [
        ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            setState(() {
              isRoomSectionExpanded = !isExpanded;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      isRoomSectionExpanded = !isExpanded;
                    });
                  },
                  title: const Text(
                    "Rooms",
                    style:  TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.grey
                    ),
                  ),
                );
              },
              body: _renderRooms(),
              isExpanded: isRoomSectionExpanded,
            )
          ],
        ),
      ],
    );
  }

  _renderCharacters() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ConstantUtils.characterList.length,
          itemBuilder: (context, index) {
            return _renderInitialCardSelectViewForEntity(
                ConstantUtils.characterList[index],
                _checkBoxPersons(ConstantUtils.characterList[index])
            );
          }
      ),
    );
  }

  _renderWeapons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ConstantUtils.weaponList.length,
          itemBuilder: (context, index) {
            return _renderInitialCardSelectViewForEntity(
                ConstantUtils.weaponList[index],
                _checkBoxWeapons(ConstantUtils.weaponList[index])
            );
          }
      ),
    );
  }

  _renderRooms() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ConstantUtils.roomList.length,
          itemBuilder: (context, index) {
            return _renderInitialCardSelectViewForEntity(
                ConstantUtils.roomList[index],
                _checkBoxRooms(ConstantUtils.roomList[index])
            );
          }
      ),
    );
  }

  _renderInitialCardSelectViewForEntity(String entityName, Widget child) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: child
        ),
        Expanded(
            flex: 8,
            child: Text(
              entityName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
        ),
      ],
    );
  }

  _checkBoxPersons(String characterName) {
    return Transform.scale(
      scale: 1.25,
      child: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          final c = Theme.of(context).primaryColor;
          if (states.contains(MaterialState.disabled)) {
            return c.withOpacity(.32);
          }
          return c;
        }),
        value: personNameToBoolMap[characterName] ?? false,
        shape: const CircleBorder(),
        onChanged: (bool? value) {
          setState(() {
            personNameToBoolMap[characterName] = value!;
          });
          final currentState = _createNewGameBloc.state;
          if (currentState is NewGameDetailsModified) {
            if (value!) {
              _createNewGameBloc.add(
                  NewGameDetailedChanged(
                      gameName: currentState.gameName,
                      totalPlayers: currentState.totalPlayers,
                      playerNames: currentState.playerNames,
                      initialCards: {...currentState.initialCards.map((e) => e.cardName()).toSet(), characterName}
                          .map((e) => GameCard.fromString(e))
                          .toList()
                  )
              );
            }
            else {
              _createNewGameBloc.add(
                  NewGameDetailedChanged(
                      gameName: currentState.gameName,
                      totalPlayers: currentState.totalPlayers,
                      playerNames: currentState.playerNames,
                      initialCards: currentState.initialCards.where((element) => element.cardName() != characterName).toList()
                  )
              );
            }
          }
        },
      ),
    );
  }

  _checkBoxWeapons(String weaponName) {
    return Transform.scale(
      scale: 1.25,
      child: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          final c = Theme.of(context).primaryColor;
          if (states.contains(MaterialState.disabled)) {
            return c.withOpacity(.32);
          }
          return c;
        }),
        value: weaponNameToBoolMap[weaponName] ?? false,
        shape: const CircleBorder(),
        onChanged: (bool? value) {
          setState(() {
            weaponNameToBoolMap[weaponName] = value!;
          });
          final currentState = _createNewGameBloc.state;
          if (currentState is NewGameDetailsModified) {
            if (value!) {
              _createNewGameBloc.add(
                  NewGameDetailedChanged(
                      gameName: currentState.gameName,
                      totalPlayers: currentState.totalPlayers,
                      playerNames: currentState.playerNames,
                      initialCards: {...currentState.initialCards.map((e) => e.cardName()).toSet(), weaponName}
                          .map((e) => GameCard.fromString(e))
                          .toList()
                  )
              );
            }
            else {
              _createNewGameBloc.add(
                  NewGameDetailedChanged(
                      gameName: currentState.gameName,
                      totalPlayers: currentState.totalPlayers,
                      playerNames: currentState.playerNames,
                      initialCards: currentState.initialCards.where((element) => element.cardName() != weaponName).toList()
                  )
              );
            }
          }
        },
      ),
    );
  }

  _checkBoxRooms(String roomName) {
    return Transform.scale(
      scale: 1.25,
      child: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          final c = Theme.of(context).primaryColor;
          if (states.contains(MaterialState.disabled)) {
            return c.withOpacity(.32);
          }
          return c;
        }),
        value: roomNameToBoolMap[roomName] ?? false,
        shape: const CircleBorder(),
        onChanged: (bool? value) {
          setState(() {
            roomNameToBoolMap[roomName] = value!;
          });
          final currentState = _createNewGameBloc.state;
          if (currentState is NewGameDetailsModified) {
            if (value!) {
              _createNewGameBloc.add(
                  NewGameDetailedChanged(
                      gameName: currentState.gameName,
                      totalPlayers: currentState.totalPlayers,
                      playerNames: currentState.playerNames,
                      initialCards: {...currentState.initialCards.map((e) => e.cardName()).toSet(), roomName}
                          .map((e) => GameCard.fromString(e))
                          .toList()
                  )
              );
            }
            else {
              _createNewGameBloc.add(
                  NewGameDetailedChanged(
                      gameName: currentState.gameName,
                      totalPlayers: currentState.totalPlayers,
                      playerNames: currentState.playerNames,
                      initialCards: currentState.initialCards.where((element) => element.cardName() != roomName).toList()
                  )
              );
            }
          }
        },
      ),
    );
  }


  _renderTotalPlayers(NewGameDetailsModified state) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Expanded(
              flex: 5,
              child: Text(
                "Total Players",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
          ),
          Expanded(
              flex: 8,
              child: TextField(
                controller: personCountTextFieldController,
                enabled: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.teal,
                    ),
                  ),
                ),
              )
            ),
        ],
      ),
    );
  }

  _renderGameNameView(NewGameDetailsModified state) {
    return Column(
      children: [
        const Text("Game name", style: TextStyle(fontSize: 16),),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: TextField(
            controller: nameTextFieldController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            enabled: false,
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

  _showHintDialogToSetupGame() {
    final currentState = _createNewGameBloc.state;
    if (currentState is NewGameDetailsModified) {
      final maxCardsPerPlayer = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / currentState.totalPlayers).floor();

      showDialog(context: context, builder: (context) {
        return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: SizedBox(
              height: ScreenUtils.getScreenHeight(context) / 2,
              child: Scaffold(
                  // appBar: AppBar(
                  //   automaticallyImplyLeading: false,
                  //   title: const Text("Game setup", style: TextStyle(color: Colors.teal),),
                  // ),
                  body: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1
                        )
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: WidgetUtils.skipNulls([
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  "Lets get started",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 20
                                  ),
                                ),
                              ),
                            ),
                            WidgetUtils.spacer(5.0),

                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  "This game consists of ${currentState.totalPlayers} players and ${ConstantUtils.MAX_GAME_CARDS} cards",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal
                                  ),
                                ),
                              ),
                            ),
                            WidgetUtils.spacer(5.0),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  "Shuffle the cards and set aside ${ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL} cards, one of each category - Character, Weapon and Room",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal
                                  ),
                                ),
                              ),
                            ),
                            WidgetUtils.spacer(5.0),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  "Shuffle the cards and distribute $maxCardsPerPlayer cards to each player. These cards can be of any category",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal
                                  ),
                                ),
                              ),
                            ),
                            WidgetUtils.spacer(5.0),
                            (maxCardsPerPlayer * currentState.totalPlayers) + ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL == ConstantUtils.MAX_GAME_CARDS ? null :
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  "Reveal ${ConstantUtils.MAX_GAME_CARDS - (maxCardsPerPlayer * currentState.totalPlayers) - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL} cards for all to see. "
                                      "This is required so that no one player has an unfair advantage.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  )
              ),
            )
        );
      }).then((value) => KeyboardUtils.hideKeyboard(context));
    }


  }

}