import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Conclusion extends StatelessWidget {
  final GameSettings gameSettings;

  const Conclusion({super.key, required this.gameSettings});

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
                    "Conclusion",
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
                  "Make sure you pay attention to others' accusations as well as who shows cards to whom.",
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
                  "Each time you notice another player showing one of the other players their card due to an accusation, note down a marking for the same.",
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
                  "Given enough observations, you should be able to infer conclusions that would let you deduce the missing cards and solve the crime.",
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
                  "For more info on how to use the ClueIn app, select \"Help\" from the menu options.",
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