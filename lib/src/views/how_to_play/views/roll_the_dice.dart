import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:flutter/material.dart';

class RollTheDice extends StatelessWidget {
  final GameSettings gameSettings;

  const RollTheDice({super.key, required this.gameSettings});

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
                    "Step 1: Roll the dice",
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
                  "Roll a pair of dice and take note of the number. This is the maximum number of squares your character can move on this turn.",
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
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "Move into a room of your choice to make an accusation. ",
                        style: TextStyle(
                            color: gameSettings.primaryColorSetting,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                        ),
                        children: const [
                          TextSpan(
                              text: "If you are unable to move to a room, your turn ends here.",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                        ]
                    )
                )
              ),
              WidgetUtils.spacer(10),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "Some rooms have trapdoors leading to other rooms. ",
                          style: TextStyle(
                            color: gameSettings.primaryColorSetting,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                          children: const [
                            TextSpan(
                                text: "You may only use a trapdoor once every time you enter the room, BEFORE you roll the dice. ",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ]
                      )
                  )
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