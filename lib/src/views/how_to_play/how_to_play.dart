import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/how_to_play/views/conclusion.dart';
import 'package:cluein_app/src/views/how_to_play/views/initial_game_setup.dart';
import 'package:cluein_app/src/views/how_to_play/views/make_an_accusation.dart';
import 'package:cluein_app/src/views/how_to_play/views/note_observations.dart';
import 'package:cluein_app/src/views/how_to_play/views/roll_the_dice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HowToPlay extends StatefulWidget {

  static const String routeName = "how-to-play";

  final GameSettings gameSettings;

  static Route<GameSettings> route(GameSettings gameSettings) => MaterialPageRoute(
    settings: const RouteSettings(
        name: routeName
    ),
    builder: (_) => HowToPlay(gameSettings: gameSettings),
  );

  const HowToPlay({
    super.key,
    required this.gameSettings
  });

  @override
  State<StatefulWidget> createState() {
    return HowToPlayState();
  }

}

class HowToPlayState extends State<HowToPlay> {
  static const int MAX_PAGES = 5;

  Widget? dynamicActionButtons;
  Icon floatingActionButtonIcon = const Icon(Icons.navigate_next, color: Colors.white);
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    dynamicActionButtons = _singleFloatingActionButton();
  }

  _singleFloatingActionButton() {
    return FloatingActionButton(
        heroTag: "CreateNewMeetupViewbutton0",
        onPressed: _onActionButtonPress,
        backgroundColor: widget.gameSettings.primaryColorSetting,
        child: floatingActionButtonIcon,
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
                heroTag: "HowToPlayButton2",
                onPressed: _onBackFloatingActionButtonPress,
                backgroundColor: widget.gameSettings.primaryColorSetting,
                child: const Icon(Icons.navigate_before, color: Colors.white)
            ),
          ),
          FloatingActionButton(
              heroTag: "HowToPlayButton1",
              onPressed: _onActionButtonPress,
              backgroundColor: widget.gameSettings.primaryColorSetting,
              child: floatingActionButtonIcon
          )
        ],
      ),
    );
  }

  _onlyBackFloatingAactionButton() {
    return Visibility(
      visible: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: FloatingActionButton(
                heroTag: "HowToPlayButton2",
                onPressed: _onBackFloatingActionButtonPress,
                backgroundColor: widget.gameSettings.primaryColorSetting,
                child: const Icon(Icons.navigate_before, color: Colors.white)
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? _onActionButtonPress() {
    final currentPage = _pageController.page;
    if (currentPage != null) {
      _moveToNextPageElseDoNothing(currentPage.toInt());
    }
  }

  _moveToNextPageElseDoNothing(int currentPage) {
    goToNextPage() => _pageController.animateToPage(currentPage + 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn
    );

    if (currentPage < MAX_PAGES - 1) {
      goToNextPage();
    }
  }

  VoidCallback? _onBackFloatingActionButtonPress() {
    final currentPage = _pageController.page;
    if (currentPage != null) {
      _goToPreviousPageOrNothing(currentPage.toInt());
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "How To Play",
          style: TextStyle(color: widget.gameSettings.primaryColorSetting),
        ),
        iconTheme: IconThemeData(
          color: widget.gameSettings.primaryColorSetting,
        ),
      ),
      body: _pageViews(),
      floatingActionButton: dynamicActionButtons,
    );
  }

  _pageViews() {
    return PageView(
      controller: _pageController,
      onPageChanged: (pageNumber) {
        _changeFloatingActionButtonsIfNeeded(pageNumber);
      },
      physics: const NeverScrollableScrollPhysics(),
      children:  [
        InitialGameSetup(gameSettings: widget.gameSettings,),
        RollTheDice(gameSettings: widget.gameSettings,),
        MakeAnAccusation(gameSettings: widget.gameSettings,),
        NoteObservations(gameSettings: widget.gameSettings,),
        Conclusion(gameSettings: widget.gameSettings,),
      ],
    );
  }

  _changeFloatingActionButtonsIfNeeded(int pageNumber) {
    if (pageNumber == 0) {
      setState(() {
        dynamicActionButtons =  _singleFloatingActionButton();
      });
    }
    else if (pageNumber == MAX_PAGES - 1) {
      setState(() {
        dynamicActionButtons = _onlyBackFloatingAactionButton();
      });
    }
    else {
      setState(() {
        dynamicActionButtons = _dynamicFloatingActionButtons();
      });
    }
  }
}