import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/save/game_definition.dart';
import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/create_new_game/create_new_game.dart';
import 'package:cluein_app/src/views/load_game/bloc/load_game_bloc.dart';
import 'package:cluein_app/src/views/load_game/bloc/load_game_event.dart';
import 'package:cluein_app/src/views/load_game/bloc/load_game_state.dart';
import 'package:cluein_app/src/views/main_game/main_game_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class LoadGameView extends StatefulWidget {
  final GameSettings gameSettings;

  static const String routeName = "load-game";

  const LoadGameView({
    super.key,
    required this.gameSettings,
  });

  static Route<bool> route(GameSettings gameSettings) => MaterialPageRoute(
    settings: const RouteSettings(
        name: routeName
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider<LoadGameBloc>(
            create: (context) => LoadGameBloc(
                sembast: RepositoryProvider.of<SembastRepository>(context)
            )),
      ],
      child: LoadGameView(gameSettings: gameSettings),
    ),
  );

@override
  State<StatefulWidget> createState() {
    return LoadGameViewState();
  }

}

class LoadGameViewState extends State<LoadGameView> {

  late LoadGameBloc loadGameBloc;

  @override
  void initState() {
    super.initState();

    loadGameBloc = BlocProvider.of<LoadGameBloc>(context);
    loadGameBloc.add(const FetchSavedGames());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Load game", style: TextStyle(color: widget.gameSettings.primaryColorSetting),),
        iconTheme: IconThemeData(
          color: widget.gameSettings.primaryColorSetting,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          heroTag: "CreateNewMeetupViewbuttonLoadGameView",
          onPressed: _goToCreateNewGamePage,
          backgroundColor: widget.gameSettings.primaryColorSetting,
          child: const Icon(Icons.add, color: Colors.white)
      ),
      body: BlocListener<LoadGameBloc, LoadGameState>(
        listener: (context, state) {

        },
        child: BlocBuilder<LoadGameBloc, LoadGameState> (
          builder: (context, state) {
            if (state is SavedGamesFetched) {
              return _showSavedGamesListView(state);
            }
            else {
              return WidgetUtils.progressIndicator(widget.gameSettings.primaryColorSetting);
            }
          },
        ),
      ),
    );
  }

  _goToCreateNewGamePage() {
    final currentState = loadGameBloc.state;
    if (currentState is SavedGamesFetched) {
      Navigator.pushReplacement(
          context,
          CreateNewGameView.route(widget.gameSettings,  currentState.savedGames.length)
      );
    }
  }

  _showSavedGamesListView(SavedGamesFetched state) {
    if (state.savedGames.isNotEmpty) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: state.savedGames.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(state.savedGames[index].gameId),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) {
                // Show dialog asking confirmation
                Widget cancelButton = TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(widget.gameSettings.primaryColorSetting),
                  ),
                  onPressed:  () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Cancel"),
                );
                Widget continueButton = TextButton(
                  onPressed:  () {
                    Navigator.pop(context, true);
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                  ),
                  child: const Text("Confirm"),
                );

                AlertDialog alert = AlertDialog(
                  title: const Text("Delete saved game confirmation"),
                  content: const Text("Are you sure you want to delete this game? This action is irreversible!"),
                  actions: [
                    cancelButton,
                    continueButton,
                  ],
                );

                // show the dialog
                return showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  _deleteCurrentGame(state.savedGames[index].gameId);
                }
              },
              background: WidgetUtils.viewUnderDismissibleListTile(),
              child: ListTile(
                onTap: () {
                  // Show dialog to confirm openin ghits game
                  _openSavedGame(state.savedGames[index]);
                },
                title: Text(
                  state.savedGames[index].gameName,
                ),
                subtitle: Text(
                  timeago.format(state.savedGames[index].lastSaved),
                ),
              ),
            );
          }
      );
    }
    else {
      return const Center(
        child: Text(
          "No saved games, get started by creating one!"
        ),
      );
    }
  }

  _openSavedGame(GameDefinition gameDefinition) {
    Navigator.push(
        context,
        MainGameView.route(
            gameDefinition: gameDefinition,
            gameSettings: widget.gameSettings,
        )
    ).then((value) => Navigator.pop(context));
  }

  _deleteCurrentGame(String gameId) {
    loadGameBloc.add(DeleteSavedGame(gameId: gameId));
  }

}