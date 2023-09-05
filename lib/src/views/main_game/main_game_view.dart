import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
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

  @override
  void initState() {
    super.initState();

    _mainGameBloc = BlocProvider.of<MainGameBloc>(context);
    // todo - enforce player ordering here
    _mainGameBloc.add(
        MainGameStateChanged(
            charactersGameState: MainGameStateModified.emptyCharactersGameState(widget.gameDefinition.playerNames.values.toList()),
            weaponsGameState: MainGameStateModified.emptyWeaponsGameState(widget.gameDefinition.playerNames.values.toList()),
            roomsGameState: MainGameStateModified.emptyRoomsGameState(widget.gameDefinition.playerNames.values.toList())
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

          }
        },
        child: WillPopScope(
          onWillPop: () {
            // todo - ask for confirmation and notify user that game state will be saved
            return Future.value(true);
          },
          child: _mainBody(),
        ),
      ),
      // floatingActionButton: dynamicActionButtons,
      // bottomNavigationBar: WidgetUtils.wrapAdWidgetWithUpgradeToMobileTextIfNeeded(adWidget, maxHeight),
    );
  }

  _mainBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ScreenUtils.getScreenWidth(context) * 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 3,
                child: _generateEntityNamesList(),
              ),
              SizedBox(
                height: ((ConstantUtils.CELL_SIZE_DEFAULT * ConstantUtils.allEntitites.length ) +
                        (9 * ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT)).toDouble(),
                child: _verticalDivider(),
              ),
              Expanded(
                flex: 7,
                child: _generateEntityMarkings(),
              )
            ],
          ),
        ),
      ),
    );
  }

  _generateEntityNamesList() {
    return Column(
      children: [
        _divider(),
        _heading("Characters"),
        _divider(),
        ListView.separated(
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
        ),
        _divider(),
        _heading("Weapons"),
        _divider(),
        ListView.separated(
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
        ),
        _divider(),
        _heading("Rooms"),
        _divider(),
        ListView.separated(
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
        ),
        _divider(),
      ],

    );
  }


  // todo - split this further
  _generateEntityMarkings() {
    return Column(
      children: [
        _divider(),
        SizedBox(
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
        ),
        _divider(),
        // Characters
        ListView.separated(
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
              final currentEntity = ConstantUtils.characterList[index];
              return GestureDetector(
                onTap: () {
                  print("Index $index has been tapped");
                },
                child: SizedBox(
                  height: 50,
                  child: Row(
                    // todo - arrange in order
                    children: widget.gameDefinition.playerNames.values.map((e) {
                      return [
                        Expanded(
                          flex: 3,
                          child: ListTile(
                            tileColor: Colors.grey.shade200,
                          ),
                        ),
                        _verticalDivider2()
                      ];
                    }).expand((element) => element).toList(),
                  ),
                ),
              );
            }
        ),
        _divider(),
        SizedBox(
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
        ),
        _divider(),
        ListView.separated(
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
                          child: ListTile(
                            tileColor: Colors.grey.shade200,
                          ),
                        ),
                        _verticalDivider2()
                      ];
                    }).expand((element) => element).toList(),
                  ),
                ),
              );
            }
        ),
        _divider(),
        SizedBox(
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
        ),
        _divider(),
        ListView.separated(
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
                          child: ListTile(
                            tileColor: Colors.grey.shade200,
                          ),
                        ),
                        _verticalDivider2()
                      ];
                    }).expand((element) => element).toList(),
                  ),
                ),
              );
            }
        ),
        _divider(),
      ],
    );
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