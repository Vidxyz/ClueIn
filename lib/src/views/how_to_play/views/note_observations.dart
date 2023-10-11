import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:flutter/material.dart';

class NoteObservations extends StatelessWidget {
  final GameSettings gameSettings;

  const NoteObservations({super.key, required this.gameSettings});

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
                    "Step 3: Note observations",
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
                  "Each player will now, in order, try to disprove your accusation by showing you one of the mentioned cards, should they possess it.",
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
                          text: "If a player cannot show you one of the cards from your accusation, then they will pass their turn.",
                          style: TextStyle(
                            color: gameSettings.primaryColorSetting,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                          children: const [
                            TextSpan(
                                text: "This means that they do not hold in their hand any of the above cards.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
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
                  "Make sure you note down these observations, as you will be able to infer conclusions from them in the future.",
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
                  "Once you have enough information, you should be able to deduce the unknown cards and solve the puzzle.",
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