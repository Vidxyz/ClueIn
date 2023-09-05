import 'package:cluein_app/src/models/game_card.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_bloc.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_event.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddInitialCardsView extends StatefulWidget {

  const AddInitialCardsView({super.key});


  @override
  State<StatefulWidget> createState() {
    return AddInitialCardsViewState();
  }
}

class AddInitialCardsViewState extends State<AddInitialCardsView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, bool> personNameToBoolMap = {};
  Map<String, bool> weaponNameToBoolMap = {};
  Map<String, bool> roomNameToBoolMap = {};

  bool isPersonSectionExpanded = true;
  bool isWeaponSectionExpanded = true;
  bool isRoomSectionExpanded = true;

  final TextEditingController nameTextFieldController = TextEditingController();
  final TextEditingController personCountTextFieldController = TextEditingController();

  late CreateNewGameBloc _createNewGameBloc;

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
  }

  @override
  Widget build(BuildContext context) {
    return  BlocListener<CreateNewGameBloc, CreateNewGameState>(
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

  _renderAllPersonCards() {
    return ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        setState(() {
          isPersonSectionExpanded = !isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return const ListTile(
              title: Text(
                "Persons",
                style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey
                ),
              ),
            );
          },
          body: _renderPersons(),
          isExpanded: isPersonSectionExpanded,
        )
      ],
    );
  }

  _renderAllWeaponsCards() {
    return ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        setState(() {
          isWeaponSectionExpanded = !isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return const ListTile(
              title: Text(
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
    );
  }

  _renderAllRoomsCards() {
    return ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        setState(() {
          isRoomSectionExpanded = !isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return const ListTile(
              title: Text(
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
    );
  }

  _renderPersons() {
    final list = ["Scarlett", "Mustard", "White", "Green", "Peacock", "Plum"];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _renderInitialCardSelectViewForEntity(list[index], _checkBoxPersons(list[index]));
          }
      ),
    );
  }

  _renderWeapons() {
    final list = ["Dagger", "Candlestick", "Revolver", "Rope", "Lead Pipe", "Wrench"];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _renderInitialCardSelectViewForEntity(list[index],  _checkBoxWeapons(list[index]));
          }
      ),
    );
  }

  _renderRooms() {
    final list = [
      "Hall", "Lounge", "DiningRoom", "Kitchen", "BallRoom", "Conservatory", "BilliardRoom", "Library", "Study"
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _renderInitialCardSelectViewForEntity(list[index], _checkBoxRooms(list[index]));
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
}