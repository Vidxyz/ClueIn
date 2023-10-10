import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/keyboard_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/main_game/main_game_view.dart';
import 'package:cluein_app/src/views/shared_components/ads/custom_markings_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef CloseDialogAndSaveStateCallback = Function(EntityType entityType, String currentEntity, String currentPlayerName);
typedef CloseDialogAndResetCellCallback = Function(EntityType entityType, String currentEntity, String currentPlayerName);
typedef SetStateAndPopIfNeededCallback = Function(String text,
    EntityType entityType,
    String currentEntity,
    String currentPlayerName
);


class MarkingsView extends StatefulWidget {
  final Color primaryColorSetting;
  // final CloseDialogAndSaveStateCallback closeDialogCallback;
  final SetStateAndPopIfNeededCallback setStateAndPopIfNeededCallback;
  final CloseDialogAndResetCellCallback closeDialogAndResetCellCallback;

  final List<String> currentMarkings;
  final EntityType entityType;
  final String currentEntity;
  final String currentPlayerName;

  final bool selectMultipleMarkingsAtOnceSetting;

  const MarkingsView({
    super.key,
    required this.primaryColorSetting,

    // required this.closeDialogCallback,
    required this.closeDialogAndResetCellCallback,
    required this.setStateAndPopIfNeededCallback,

    required this.currentMarkings,
    required this.entityType,
    required this.currentEntity,
    required this.currentPlayerName,

    required this.selectMultipleMarkingsAtOnceSetting,
  });


  @override
  State<StatefulWidget> createState() {
    return MarkingsViewState();
  }

}

class MarkingsViewState extends State<MarkingsView> {

  List<String> selectedMarkingsFromDialogState = [];

  @override
  void initState() {
    super.initState();

    selectedMarkingsFromDialogState = widget.currentMarkings;
  }

  _resetCellButton() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(widget.primaryColorSetting),
        ),
        onPressed: () async {
          widget.closeDialogAndResetCellCallback(widget.entityType, widget.currentEntity, widget.currentPlayerName);
          Navigator.pop(context, true);
        },
        child: const Text("Reset cell", style: TextStyle(fontSize: 15, color: Colors.white)),
      ),
    );
  }

  _dismissDialogButton() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(widget.primaryColorSetting),
        ),
        onPressed: () async {
          // widget.closeDialogCallback(widget.entityType, widget.currentEntity, widget.currentPlayerName);
          Navigator.pop(context, false);
        },
        child: const Text("Go back", style: TextStyle(fontSize: 15, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  "Current markings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.primaryColorSetting
                  ),
                ),
              ),
            ),
            WidgetUtils.spacer(2.5),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(
                      color: widget.primaryColorSetting,
                      width: 2.5
                  )
              ),
              child: SizedBox(
                height: 120,
                child: widget.currentMarkings.isEmpty ? Container() : CustomMarkingsLayout(
                  isPartOfDialog: true,
                  children: widget.currentMarkings.map((marking) {
                    return _maybeMarkerVanilla(marking, () {
                      setStateAndPopIfNeededCallback(marking,  widget.entityType, widget.currentEntity, widget.currentPlayerName);
                    });
                  }).toList(),
                ),
              ),
            ),
            WidgetUtils.spacer(2.5),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(
                child: Text(
                  "Select a marker to apply to the ${widget.entityType.name}/Player combo",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: widget.primaryColorSetting
                  ),
                ),
              ),
            ),
            WidgetUtils.spacer(2.5),
            _divider(),
            Text(
              "Symbols",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.primaryColorSetting,
                fontSize: 16,
              ),
            ),
            WidgetUtils.spacer(2.5),
            Row(
              children: [
                Expanded(
                  // Check marker
                    child: SizedBox(
                      width: 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedMarkingsFromDialogState.contains(ConstantUtils.tick)) {
                              selectedMarkingsFromDialogState.remove(ConstantUtils.tick);
                            }
                            else {
                              selectedMarkingsFromDialogState.add(ConstantUtils.tick);
                            }
                          });
                          widget.setStateAndPopIfNeededCallback(ConstantUtils.tick, widget.entityType, widget.currentEntity, widget.currentPlayerName);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                ),
                Expanded(
                  // Cross marker
                    child: SizedBox(
                      width: 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedMarkingsFromDialogState.contains(ConstantUtils.questionMark)) {
                              selectedMarkingsFromDialogState.remove(ConstantUtils.questionMark);
                            }
                            else {
                              selectedMarkingsFromDialogState.add(ConstantUtils.questionMark);
                            }
                          });
                          widget.setStateAndPopIfNeededCallback(ConstantUtils.questionMark, widget.entityType, widget.currentEntity, widget.currentPlayerName);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Icon(Icons.warning, size: 16, color: Colors.white,),
                        ),
                      ),
                    )
                ),
                Expanded(
                  // Cross marker
                    child: SizedBox(
                      width: 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedMarkingsFromDialogState.contains(ConstantUtils.cross)) {
                              selectedMarkingsFromDialogState.remove(ConstantUtils.cross);
                            }
                            else {
                              selectedMarkingsFromDialogState.add(ConstantUtils.cross);
                            }
                          });
                          widget.setStateAndPopIfNeededCallback(ConstantUtils.cross, widget.entityType, widget.currentEntity, widget.currentPlayerName);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child: Icon(Icons.close, size: 16, color: Colors.white,),
                        ),
                      ),
                    )
                ),
              ],
            ),
            WidgetUtils.spacer(2.5),
            _divider(),
            Text(
              "Numbers",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.primaryColorSetting,
                fontSize: 16,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ScreenUtils.isPortraitOrientation(context) ? 6 : 12,
              children: [
                _maybeMarker("1", selectedMarkingsFromDialogState.contains("1"), () {
                  setStateAndPopIfNeededCallback("1", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("2", selectedMarkingsFromDialogState.contains("2"), () {
                  setStateAndPopIfNeededCallback("2", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("3", selectedMarkingsFromDialogState.contains("3"),  () {
                  setStateAndPopIfNeededCallback("3", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("4", selectedMarkingsFromDialogState.contains("4"), () {
                  setStateAndPopIfNeededCallback("4", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("5", selectedMarkingsFromDialogState.contains("5"),  () {
                  setStateAndPopIfNeededCallback("5", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("6", selectedMarkingsFromDialogState.contains("6"),  () {
                  setStateAndPopIfNeededCallback("6", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("7", selectedMarkingsFromDialogState.contains("7"),  () {
                  setStateAndPopIfNeededCallback("7", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("8", selectedMarkingsFromDialogState.contains("8"),  () {
                  setStateAndPopIfNeededCallback("8", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("9", selectedMarkingsFromDialogState.contains("9"),  () {
                  setStateAndPopIfNeededCallback("9", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("10", selectedMarkingsFromDialogState.contains("10"),  () {
                  setStateAndPopIfNeededCallback("10", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("11", selectedMarkingsFromDialogState.contains("11"),  () {
                  setStateAndPopIfNeededCallback("11", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("12", selectedMarkingsFromDialogState.contains("12"),  () {
                  setStateAndPopIfNeededCallback("12", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
              ],
            ),
            WidgetUtils.spacer(2.5),
            _divider(),
            Text(
              "Letters",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.primaryColorSetting,
                fontSize: 16,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ScreenUtils.isPortraitOrientation(context) ? 6 : 12,
              children: [
                _maybeMarker("A", selectedMarkingsFromDialogState.contains("A"), () {
                  setStateAndPopIfNeededCallback("A", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("B", selectedMarkingsFromDialogState.contains("B"), () {
                  setStateAndPopIfNeededCallback("B", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("C", selectedMarkingsFromDialogState.contains("C"),  () {
                  setStateAndPopIfNeededCallback("C", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("D", selectedMarkingsFromDialogState.contains("D"), () {
                  setStateAndPopIfNeededCallback("D", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("E", selectedMarkingsFromDialogState.contains("E"),  () {
                  setStateAndPopIfNeededCallback("E", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("F", selectedMarkingsFromDialogState.contains("F"),  () {
                  setStateAndPopIfNeededCallback("F", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("G", selectedMarkingsFromDialogState.contains("G"),  () {
                  setStateAndPopIfNeededCallback("G", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("H", selectedMarkingsFromDialogState.contains("H"),  () {
                  setStateAndPopIfNeededCallback("H", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("I", selectedMarkingsFromDialogState.contains("I"),  () {
                  setStateAndPopIfNeededCallback("I", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("J", selectedMarkingsFromDialogState.contains("J"),  () {
                  setStateAndPopIfNeededCallback("J", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("K", selectedMarkingsFromDialogState.contains("K"),  () {
                  setStateAndPopIfNeededCallback("K", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
                _maybeMarker("L", selectedMarkingsFromDialogState.contains("L"),  () {
                  setStateAndPopIfNeededCallback("L", widget.entityType, widget.currentEntity, widget.currentPlayerName);
                }),
              ],
            ),
            WidgetUtils.spacer(2.5),
            _divider(),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: _dismissDialogButton(),
          ),
          Expanded(
            child: _resetCellButton(),
          ),
        ],
      ),
    );
  }

  setStateAndPopIfNeededCallback(String currentMarking, EntityType entityType, String currentEntity, String currentPlayerName) {
    KeyboardUtils.mediumImpact();
    setState(() {
      if (selectedMarkingsFromDialogState.contains(currentMarking)) {
        selectedMarkingsFromDialogState.remove(currentMarking);
      }
      else {
        selectedMarkingsFromDialogState.add(currentMarking);
      }
    });
    widget.setStateAndPopIfNeededCallback(currentMarking, widget.entityType, widget.currentEntity, widget.currentPlayerName);
  }
  
  _divider() {
    return Divider(
      height: ConstantUtils.HORIZONTAL_DIVIDER_SIZE_DEFAULT.toDouble(),
      thickness: 5,
      endIndent: 0,
      color: widget.primaryColorSetting,
    );
  }

  Widget _maybeMarkerVanilla(String text, VoidCallback onTap) {
    if (text == ConstantUtils.tick) {
      return SizedBox(
        width: 50,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
              onTap: onTap,
              child: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.check, color: Colors.white, size: ConstantUtils.MARKING_ICON_DIAMETER_2,),
              )
          ),
        ),
      );

    }
    else if (text == ConstantUtils.cross) {
      return SizedBox(
        width: 50,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: onTap,
              child: const CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.close, size: ConstantUtils.MARKING_ICON_DIAMETER_2, color: Colors.white,),
              ),
            )
        ),
      );

    }
    else if (text == ConstantUtils.questionMark) {
      return SizedBox(
        width: 50,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: onTap,
              child: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.warning, size: ConstantUtils.MARKING_ICON_DIAMETER_2, color: Colors.white,),
              ),
            )
        ),
      );
    }
    else {
      return SizedBox(
        width: 50,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: widget.primaryColorSetting
                  )
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _maybeMarker(String text, bool isSelectedAlready, VoidCallback onTap) {
    return SizedBox(
      width: 30,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: isSelectedAlready ? Colors.redAccent : widget.primaryColorSetting,
            child: Text(
                text,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ),
      ),
    );
  }
}