import 'dart:js_interop';

import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/snackbar_utils.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_bloc.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_event.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_state.dart';
import 'package:cluein_app/src/views/create_new_game/views/add_basic_game_details.dart';
import 'package:cluein_app/src/views/create_new_game/views/add_initial_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateNewGameView extends StatefulWidget {
  static const String routeName = 'new-game';

  const CreateNewGameView({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
        settings: const RouteSettings(
            name: routeName
        ),
        builder: (_) =>
            MultiBlocProvider(
              providers: [
                BlocProvider<CreateNewGameBloc>(
                    create: (context) => CreateNewGameBloc()
                ),
              ],
              child: CreateNewGameView(),
            ));
  }


  @override
  State createState() {
    return CreateNewGameViewState();
  }

}

// Follow similar model to create new meetup/create new user flow
class CreateNewGameViewState extends State<CreateNewGameView> {

  Icon floatingActionButtonIcon = const Icon(Icons.navigate_next, color: Colors.white);
  final PageController _pageController = PageController();

  Widget? dynamicActionButtons;

  late CreateNewGameBloc _createNewGameBloc;

  @override
  void initState() {
    super.initState();

    dynamicActionButtons = _singleFloatingActionButton();
    _createNewGameBloc = BlocProvider.of<CreateNewGameBloc>(context);
    _createNewGameBloc.add(
        const NewGameDetailedChanged(
            gameName: "",
            totalPlayers: 6,
            playerNames: {},
            initialCards: []
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Game', style: TextStyle(color: Colors.teal),),
        iconTheme: const IconThemeData(
          color: Colors.teal,
        ),
      ),
      body: BlocListener<CreateNewGameBloc, CreateNewGameState>(
        listener: (context, state) {
          if (state is NewGameDetailsModified) {

          }
          else if (state is NewGameSavedAndReadyToStart) {
            // todo - Lets fkn goooo to the game
          }
        },
        child: _pageViews(),
      ),
      floatingActionButton: dynamicActionButtons,
      // bottomNavigationBar: WidgetUtils.wrapAdWidgetWithUpgradeToMobileTextIfNeeded(adWidget, maxHeight),
    );
  }


  _changeButtonIconIfNeeded(int pageNumber) {
    if (pageNumber == 1) {
      setState(() {
        floatingActionButtonIcon = const Icon(Icons.check, color: Colors.white);
      });
    }
    else {
      setState(() {
        floatingActionButtonIcon = const Icon(Icons.navigate_next, color: Colors.white);
      });
    }
  }

  _changeFloatingActionButtonsIfNeeded(int pageNumber) {
    if (pageNumber == 0) {
      setState(() {
        dynamicActionButtons =  _singleFloatingActionButton();
      });
    }
    else {
      setState(() {
        dynamicActionButtons = _dynamicFloatingActionButtons();
      });
    }
  }

  Widget _pageViews() {
    return BlocBuilder<CreateNewGameBloc, CreateNewGameState>(
        builder: (context, state) {
          if (state is NewGameDetailsModified) {
            return PageView(
              controller: _pageController,
              onPageChanged: (pageNumber) {
                _changeButtonIconIfNeeded(pageNumber);
                _changeFloatingActionButtonsIfNeeded(pageNumber);
              },
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                AddBasicGameDetailsView(),
                AddInitialCardsView(),
              ],
            );
          }
          else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  _singleFloatingActionButton() {
    return FloatingActionButton(
        heroTag: "CreateNewMeetupViewbutton0",
        onPressed: _onActionButtonPress,
        backgroundColor: Colors.teal,
        child: floatingActionButtonIcon
    );
  }

  _dynamicFloatingActionButtons() {
    return Visibility(
      visible: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: FloatingActionButton(
                heroTag: "CreateNewMeetupViewbutton1",
                onPressed: _onBackFloatingActionButtonPress,
                backgroundColor: Colors.teal,
                child: const Icon(Icons.navigate_before, color: Colors.white)
            ),
          ),
          FloatingActionButton(
              heroTag: "CreateNewMeetupViewbutton2",
              onPressed: _onActionButtonPress,
              backgroundColor: Colors.teal,
              child: floatingActionButtonIcon
          )
        ],
      ),
    );
  }

  void _goToPreviousPageOrNothing(int currentPage) {
    if (currentPage != 0) {
      // Move to previous page if not at first page
      _pageController.animateToPage(currentPage - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut
      );
    }
  }

  VoidCallback? _onBackFloatingActionButtonPress() {
    final currentState = _createNewGameBloc.state;
    if (currentState is NewGameDetailsModified) {
      final currentPage = _pageController.page;
      if (currentPage != null) {
        _goToPreviousPageOrNothing(currentPage.toInt());
      }
    }
    return null;
  }

  VoidCallback? _onActionButtonPress() {
    final currentState = _createNewGameBloc.state;
    if (currentState is NewGameDetailsModified) {
      final currentPage = _pageController.page;
      if (currentPage != null) {
        if (_isPageDataValid(currentPage.toInt(), currentState)) {
          _savePageData(currentPage.toInt(), currentState);
          _moveToNextPageElseDoNothing(currentPage.toInt(), currentState);
        }
        else {
          if (currentPage == 0) {
            if (currentState.gameName.isEmpty) {
              SnackbarUtils.showSnackBarShort(context, "Please add a name for the game");
            }
            else {
              SnackbarUtils.showSnackBarShort(context, "Please add all names");
            }
          }
          else {
            print(currentState.initialCards);
            print('-------------');
            final maxCards = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / currentState.totalPlayers).floor();
            SnackbarUtils.showSnackBarShort(context, "Please select exactly $maxCards cards");
          }
        }
      }
    }
    return null;
  }

  bool _isPageDataValid(int pageNumber, NewGameDetailsModified state) {
    gameHasValidName() => state.gameName.isNotEmpty;
    playerNamesEqualPlayerCount() => state.playerNames.length >= state.totalPlayers && state.totalPlayers != 0;
    initialCardCountEqualsExpected() => state.initialCards.length ==
        ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / state.totalPlayers).floor();

    switch (pageNumber) {
      case 0:
      // Validate that everyone has a name, game has a name
        return playerNamesEqualPlayerCount() && gameHasValidName();
      case 1:
      // Validate rest of the meetup data
        return playerNamesEqualPlayerCount() && gameHasValidName() && initialCardCountEqualsExpected();
      default:
        return false;
    }
  }

  void _moveToNextPageElseDoNothing(int currentPage, NewGameDetailsModified state) {
    if (currentPage < 1) {
      // Move to next page if not at last page
      _pageController.animateToPage(currentPage + 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn
      );
    }
  }

  void _savePageData(int pageNumber, NewGameDetailsModified state) {
    switch (pageNumber) {
      case 0:
      // Nothing to do here
        return;
      case 1:
        final currentState = _createNewGameBloc.state;
        if (currentState is NewGameDetailsModified) {
          _createNewGameBloc.add(
              BeginNewClueGame(
                  gameName: currentState.gameName,
                  totalPlayers: currentState.totalPlayers,
                  playerNames: currentState.playerNames,
                  initialCards: currentState.initialCards
              )
          );
        }
        return;
      default:
        return;
    }
  }
}