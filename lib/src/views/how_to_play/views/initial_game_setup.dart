import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:flutter/material.dart';

class InitialGameSetup extends StatelessWidget {
  final GameSettings gameSettings;

  const InitialGameSetup({super.key, required this.gameSettings});


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtils.getScreenHeight(context),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(
                color: gameSettings.primaryColorSetting,
                width: 1
            )
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              WidgetUtils.spacer(5),
              WidgetUtils.divider(gameSettings.primaryColorSetting),
              WidgetUtils.spacer(5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Initial Setup",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: gameSettings.primaryColorSetting,
                    ),
                  ),
                ),
              ),
              WidgetUtils.spacer(5),
              WidgetUtils.divider(gameSettings.primaryColorSetting),
              WidgetUtils.spacer(5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "There's been a murder at the Clue mansion, and everyone is a suspect! It is upto YOU to figure out who did what where!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: gameSettings.primaryColorSetting,
                    fontSize: 16,
                  ),
                ),
              ),
              WidgetUtils.spacer(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Set aside 3 cards, one from each category - Characters, Weapons and Rooms",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    color: gameSettings.primaryColorSetting,
                    fontSize: 16,
                  ),
                ),
              ),
              WidgetUtils.spacer(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Shuffle the rest of the cards and distribute them evenly.\nIf the cards do not divide evenly, flip open the extra cards for all to see.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    color: gameSettings.primaryColorSetting,
                    fontSize: 16,
                  ),
                ),
              ),
              WidgetUtils.spacer(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Select a character and identify where on the board you start from.\nThis is the piece you will use to move around.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    color: gameSettings.primaryColorSetting,
                    fontSize: 16,
                  ),
                ),
              ),
              WidgetUtils.spacer(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Players take turns making rolling the dice and making accusations in a clockwise manner",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    color: gameSettings.primaryColorSetting,
                    fontSize: 16,
                  ),
                ),
              ),
              WidgetUtils.spacer(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Anyone can start the game",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    color: gameSettings.primaryColorSetting,
                    fontSize: 16,
                  ),
                ),
              ),
              WidgetUtils.spacer(5),
              WidgetUtils.divider(gameSettings.primaryColorSetting),
              WidgetUtils.spacer(5),
            ],
          ),
        ),
      ),
    );
  }
}