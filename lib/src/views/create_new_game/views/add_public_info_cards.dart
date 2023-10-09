import 'package:cluein_app/src/models/game_card.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/keyboard_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_bloc.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_event.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_state.dart';
import 'package:cluein_app/src/views/main_game/main_game_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AddPublicInfoCardsView extends StatefulWidget {
  final int maxCardsPublicInfo;

  const AddPublicInfoCardsView({
    super.key,
    required this.maxCardsPublicInfo,
  });

  @override
  State<StatefulWidget> createState() {
    return AddPublicInfoCardsViewState();
  }
}

class AddPublicInfoCardsViewState extends State<AddPublicInfoCardsView> with WidgetsBindingObserver {


  Map<String, bool> characterNameToBoolMap = {};
  Map<String, bool> weaponNameToBoolMap = {};
  Map<String, bool> roomNameToBoolMap = {};

  bool isPersonSectionExpanded = true;
  bool isWeaponSectionExpanded = true;
  bool isRoomSectionExpanded = true;

  final TextEditingController nameTextFieldController = TextEditingController();
  final TextEditingController personCountTextFieldController = TextEditingController();

  late CreateNewGameBloc _createNewGameBloc;

  bool hasHintTutorialBeenShown = false;


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
      if (!hasHintTutorialBeenShown) {
        hasHintTutorialBeenShown = true;
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
                      _renderAllPersonCards(state),
                      WidgetUtils.spacer(2.5),
                      _renderAllWeaponsCards(state),
                      WidgetUtils.spacer(2.5),
                      _renderAllRoomsCards(state),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          "Please select the ${widget.maxCardsPublicInfo} cards that has been set aside for everyone to know.",
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: ConstantUtils.primaryAppColor,
              fontSize: 14,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  _renderAllPersonCards(NewGameDetailsModified state) {
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
                    "Characters",
                    style:  TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.grey
                    ),
                  ),
                );
              },
              body: _renderCharacters(state),
              isExpanded: isPersonSectionExpanded,
            )
          ],
        ),
      ],
    );
  }

  _renderAllWeaponsCards(NewGameDetailsModified state) {
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
              body: _renderWeapons(state),
              isExpanded: isWeaponSectionExpanded,
            )
          ],
        ),
      ],
    );
  }

  _renderAllRoomsCards(NewGameDetailsModified state) {
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
              body: _renderRooms(state),
              isExpanded: isRoomSectionExpanded,
            )
          ],
        ),
      ],
    );
  }

  _renderCharacters(NewGameDetailsModified state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ConstantUtils.characterList.length,
          itemBuilder: (context, index) {
            final isDisabled = state.initialCards.map((e) => e.cardName()).contains(ConstantUtils.characterList[index]);
            return _renderInitialCardSelectViewForEntity(
                EntityType.Character,
                ConstantUtils.characterList[index],
                _checkBoxPersons(ConstantUtils.characterList[index], isDisabled: isDisabled),
                isDisabled: isDisabled
            );
          }
      ),
    );
  }

  _renderWeapons(NewGameDetailsModified state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ConstantUtils.weaponList.length,
          itemBuilder: (context, index) {
            final isDisabled = state.initialCards.map((e) => e.cardName()).contains(ConstantUtils.weaponList[index]);
            return _renderInitialCardSelectViewForEntity(
                EntityType.Weapon,
                ConstantUtils.weaponList[index],
                _checkBoxWeapons(ConstantUtils.weaponList[index], isDisabled: isDisabled),
                isDisabled: isDisabled
            );
          }
      ),
    );
  }

  _renderRooms(NewGameDetailsModified state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ConstantUtils.roomList.length,
          itemBuilder: (context, index) {
            final isDisabled = state.initialCards.map((e) => e.cardName()).contains(ConstantUtils.roomList[index]);
            return _renderInitialCardSelectViewForEntity(
                EntityType.Room,
                ConstantUtils.roomList[index],
                _checkBoxRooms(ConstantUtils.roomList[index], isDisabled: isDisabled),
                isDisabled: isDisabled
            );
          }
      ),
    );
  }

  _renderInitialCardSelectViewForEntity(
      EntityType entityType,
      String entityName,
      Widget child,
      {bool isDisabled = false}
      ) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: child
        ),
        Expanded(
            flex: 8,
            child: InkWell(
              onTap: () {
                if (!isDisabled) {
                  if (entityType == EntityType.Room) {
                    setState(() {
                      roomNameToBoolMap[entityName] = !(roomNameToBoolMap[entityName] ?? false);
                    });
                    _updateBlocState(entityName, roomNameToBoolMap[entityName]);
                  }
                  else if (entityType == EntityType.Weapon) {
                    setState(() {
                      weaponNameToBoolMap[entityName] = !(weaponNameToBoolMap[entityName] ?? false);
                    });
                    _updateBlocState(entityName, weaponNameToBoolMap[entityName]);
                  }
                  else {
                    setState(() {
                      characterNameToBoolMap[entityName] = !(characterNameToBoolMap[entityName] ?? false);
                    });
                    _updateBlocState(entityName, characterNameToBoolMap[entityName]);
                  }
                }
              },
              child: Text(
                entityName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey : null
                ),
              ),
            )
        ),
      ],
    );
  }

  _checkBoxPersons(String characterName, {bool isDisabled = false}) {
    return Transform.scale(
      scale: 1.25,
      child: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          const c = ConstantUtils.primaryAppColor;
          if (states.contains(MaterialState.disabled)) {
            return c.withOpacity(.32);
          }
          return c;
        }),
        value: characterNameToBoolMap[characterName] ?? false,
        shape: const CircleBorder(),
        onChanged: (bool? value) {
          if (!isDisabled) {
            setState(() {
              characterNameToBoolMap[characterName] = value!;
            });
            _updateBlocState(characterName, value);
          }
        },
      ),
    );
  }

  _updateBlocState(String entityName, bool? value) {
    final currentState = _createNewGameBloc.state;
    if (currentState is NewGameDetailsModified) {
      if (value!) {
        _createNewGameBloc.add(
            NewGameDetailedChanged(
                gameName: currentState.gameName,
                totalPlayers: currentState.totalPlayers,
                playerNames: currentState.playerNames,
                initialCards: currentState.initialCards,
                publicInfoCards: {...currentState.publicInfoCards.map((e) => e.cardName()).toSet(), entityName}
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
                initialCards: currentState.initialCards,
                publicInfoCards: currentState.publicInfoCards.where((element) => element.cardName() != entityName).toList()
            )
        );
      }
    }
  }

  _checkBoxWeapons(String weaponName, {bool isDisabled = false}) {
    return Transform.scale(
      scale: 1.25,
      child: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          const c = ConstantUtils.primaryAppColor;
          if (states.contains(MaterialState.disabled)) {
            return c.withOpacity(.32);
          }
          return c;
        }),
        value: weaponNameToBoolMap[weaponName] ?? false,
        shape: const CircleBorder(),
        onChanged: (bool? value) {
          if (!isDisabled) {
            setState(() {
              weaponNameToBoolMap[weaponName] = value!;
            });
            _updateBlocState(weaponName, value);
          }
        },
      ),
    );
  }

  _checkBoxRooms(String roomName, {bool isDisabled = false}) {
    return Transform.scale(
      scale: 1.25,
      child: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          const c = ConstantUtils.primaryAppColor;
          if (states.contains(MaterialState.disabled)) {
            return c.withOpacity(.32);
          }
          return c;
        }),
        value: roomNameToBoolMap[roomName] ?? false,
        shape: const CircleBorder(),
        onChanged: (bool? value) {
          if (!isDisabled) {
            setState(() {
              roomNameToBoolMap[roomName] = value!;
            });
            _updateBlocState(roomName, value);
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
                      color: ConstantUtils.primaryAppColor,
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