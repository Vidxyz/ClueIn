import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/snackbar_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_bloc.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_event.dart';
import 'package:cluein_app/src/views/create_new_game/bloc/create_new_game_state.dart';
import 'package:cluein_app/src/views/create_new_game/views/add_basic_game_details.dart';
import 'package:cluein_app/src/views/create_new_game/views/add_initial_cards.dart';
import 'package:cluein_app/src/views/create_new_game/views/add_public_info_cards.dart';
import 'package:cluein_app/src/views/main_game/main_game_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

GlobalKey userPromptTextKey = GlobalKey();

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
                    create: (context) => CreateNewGameBloc(
                      sembast: RepositoryProvider.of<SembastRepository>(context)
                    )
                ),
              ],
              child: const CreateNewGameView(),
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
        title: Text(
          'New Game',
          key: userPromptTextKey,
          style: const TextStyle(color: ConstantUtils.primaryAppColor),
        ),
        iconTheme: const IconThemeData(
          color: ConstantUtils.primaryAppColor,
        ),
      ),
      body: BlocListener<CreateNewGameBloc, CreateNewGameState>(
        listener: (context, state) {
          if (state is NewGameDetailsModified) {

          }
          else if (state is NewGameSavedAndReadyToStart) {
            Navigator.pushReplacement(
                context,
                MainGameView.route(gameDefinition: state.gameDefinition)
            );
          }
        },
        child: _pageViews(),
      ),
      floatingActionButton: dynamicActionButtons,
      // bottomNavigationBar: WidgetUtils.wrapAdWidgetWithUpgradeToMobileTextIfNeeded(adWidget, maxHeight),
    );
  }


  getPublicInfoCardCount(NewGameDetailsModified currentState) {
    final maxCards = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / currentState.totalPlayers).floor();
    return ConstantUtils.MAX_GAME_CARDS - (maxCards * currentState.totalPlayers) - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL;
  }

  isPublicInfoCardCountZero(NewGameDetailsModified currentState) {
    return getPublicInfoCardCount(currentState) == 0;
  }

  _changeButtonIconIfNeeded(int pageNumber) {
    if (pageNumber == 1) {
      final currentState = _createNewGameBloc.state;
      if (currentState is NewGameDetailsModified) {
        final maxCards = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / currentState.totalPlayers).floor();
        final publicInfoCardCount = ConstantUtils.MAX_GAME_CARDS - (maxCards * currentState.totalPlayers) - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL;
        if (publicInfoCardCount == 0) {
          setState(() {
            floatingActionButtonIcon = const Icon(Icons.check, color: Colors.white);
          });
        }
      }
    }
    else if (pageNumber == 2) {
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
              children: WidgetUtils.skipNulls( [
                const AddBasicGameDetailsView(),
                const AddInitialCardsView(),
                !isPublicInfoCardCountZero(state) ? AddPublicInfoCardsView(maxCardsPublicInfo: getPublicInfoCardCount(state)) : null,
              ]),
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
        backgroundColor: ConstantUtils.primaryAppColor,
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
                backgroundColor: ConstantUtils.primaryAppColor,
                child: const Icon(Icons.navigate_before, color: Colors.white)
            ),
          ),
          FloatingActionButton(
              heroTag: "CreateNewMeetupViewbutton2",
              onPressed: _onActionButtonPress,
              backgroundColor: ConstantUtils.primaryAppColor,
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
          else if (currentPage == 1) {
            final maxCards = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / currentState.totalPlayers).floor();
            SnackbarUtils.showSnackBarShort(context, "Please select exactly $maxCards cards");
          }
          else {
            final maxCards = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / currentState.totalPlayers).floor();
            final publicInfoCardCount = ConstantUtils.MAX_GAME_CARDS - (maxCards * currentState.totalPlayers) - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL;
            SnackbarUtils.showSnackBarShort(context, "Please select exactly $publicInfoCardCount cards");
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

    publicInfoCardCountEqualsExpected() {
      final maxCardsPerPlayer = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / state.totalPlayers).floor();
      final publicInfoCardCount = ConstantUtils.MAX_GAME_CARDS - (maxCardsPerPlayer * state.totalPlayers) - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL;
      return publicInfoCardCount == state.publicInfoCards.length;
    }


    switch (pageNumber) {
      case 0:
      // Validate that everyone has a name, game has a name
        return playerNamesEqualPlayerCount() && gameHasValidName();
      case 1:
      // Validate rest of the meetup data
        return playerNamesEqualPlayerCount() && gameHasValidName() && initialCardCountEqualsExpected();
      case 2:
        return playerNamesEqualPlayerCount() && gameHasValidName() && initialCardCountEqualsExpected() && publicInfoCardCountEqualsExpected();
      default:
        return false;
    }
  }

  void _moveToNextPageElseDoNothing(int currentPage, NewGameDetailsModified state) {
    goToNextPage() => _pageController.animateToPage(currentPage + 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn
    );

    if (currentPage < 2) {
      if (currentPage == 1) {
        final maxCardsPerPlayer = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / state.totalPlayers).floor();
        final publicInfoCardCount = ConstantUtils.MAX_GAME_CARDS - (maxCardsPerPlayer * state.totalPlayers) - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL;
        if (publicInfoCardCount != 0) {
          goToNextPage();
        }
      }
      else {
        // Move to next page if not at last page
        goToNextPage();
      }
    }
  }

  void _savePageData(int pageNumber, NewGameDetailsModified state) {
    startNewGame() {
      final currentState = _createNewGameBloc.state;
      if (currentState is NewGameDetailsModified) {
        _createNewGameBloc.add(
            BeginNewClueGame(
              gameName: currentState.gameName,
              totalPlayers: currentState.totalPlayers,
              playerNames: currentState.playerNames,
              initialCards: currentState.initialCards,
              publicInfoCards: currentState.publicInfoCards,
            )
        );
      }
    }

    switch (pageNumber) {
      case 0:
      // Nothing to do here
        return;
      case 1:
        final maxCardsPerPlayer = ((ConstantUtils.MAX_GAME_CARDS - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL) / state.totalPlayers).floor();
        final publicInfoCardCount = ConstantUtils.MAX_GAME_CARDS - (maxCardsPerPlayer * state.totalPlayers) - ConstantUtils.MAX_CARD_UNKNOWN_BY_ALL;
        if (publicInfoCardCount == 0) {
          startNewGame();
        }
        return;
      case 2:
        startNewGame();
        return;
      default:
        return;
    }
  }
}