import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:flutter/material.dart';

class MakeAnAccusation extends StatelessWidget {
  final GameSettings gameSettings;

  const MakeAnAccusation({super.key, required this.gameSettings});

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
                    "Step 2: Make an accusation",
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
                  "If you moved to a new room by either entering it or using a trapdoor, you may proceed to make an accusation.",
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
                          text: "An accusation is of the form - ",
                          style: TextStyle(
                            color: gameSettings.primaryColorSetting,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                          children: const [
                            TextSpan(
                                text: "\"I accuse ",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                )
                            ),
                            TextSpan(
                                text: "<Character>",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            TextSpan(
                                text: " of committing the crime in the ",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                )
                            ),
                            TextSpan(
                                text: "<Room>",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            TextSpan(
                                text: " with the ",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                )
                            ),
                            TextSpan(
                                text: "<Weapon>.",
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
                          text: "For example, I accuse ",
                          style: TextStyle(
                            color: gameSettings.primaryColorSetting,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                                text: "Mr. Green",
                                style: TextStyle(
                                  color: gameSettings.primaryColorSetting,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                )
                            ),
                            TextSpan(
                                text: " of committing the crime",
                                style: TextStyle(
                                    color: gameSettings.primaryColorSetting,
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold
                                )
                            ),
                            TextSpan(
                                text: " of committing the crime in the ",
                                style: TextStyle(
                                  color: gameSettings.primaryColorSetting,
                                  fontSize: 16,
                                )
                            ),
                            TextSpan(
                                text: "Hall",
                                style: TextStyle(
                                    color: gameSettings.primaryColorSetting,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            TextSpan(
                                text: " with the ",
                                style: TextStyle(
                                  color: gameSettings.primaryColorSetting,
                                  fontSize: 16,
                                )
                            ),
                            TextSpan(
                                text: "Dagger.",
                                style: TextStyle(
                                    color: gameSettings.primaryColorSetting,
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
                child: Text(
                  "All other players will now attempt to disprove your accusation by secretly showing you one of the mentioned cards, should they have it.",
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