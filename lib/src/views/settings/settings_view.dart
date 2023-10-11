import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/models/settings/game_settings.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/screen_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/settings/bloc/settings_bloc.dart';
import 'package:cluein_app/src/views/settings/bloc/settings_event.dart';
import 'package:cluein_app/src/views/settings/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsView extends StatefulWidget {
  static const String routeName = "settings";

  final GameSettings gameSettings;

  const SettingsView({super.key,
    required this.gameSettings,
  });

  static Route<GameSettings> route(GameSettings gameSettings) => MaterialPageRoute(
    settings: const RouteSettings(
        name: routeName
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              sembast: RepositoryProvider.of<SembastRepository>(context),
            )),
      ],
      child: SettingsView(gameSettings: gameSettings),
    ),
  );

  @override
  State<StatefulWidget> createState() {
    return SettingsViewState();
  }
}

class SettingsViewState extends State<SettingsView> {

  late SettingsBloc settingsGameBloc;


  int primaryAppColorSettingsValue = ConstantUtils.primaryAppColor.value;
  bool selectMultipleMarkingsAtOnceSettingsValue = false;
  ClueVersion clueVersionSettingsValue = ConstantUtils.defaultClueVersion;

  Color lastSelectedColorValue = ConstantUtils.primaryAppColor;

  @override
  void initState() {
    super.initState();

    settingsGameBloc = BlocProvider.of<SettingsBloc>(context);
    settingsGameBloc.add(const FetchSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Color(primaryAppColorSettingsValue)),),
        iconTheme: IconThemeData(
          color: Color(primaryAppColorSettingsValue),
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pop(
            context,
            GameSettings(
                primaryColorSetting: Color(primaryAppColorSettingsValue),
                selectMultipleMarkingsAtOnceSetting: selectMultipleMarkingsAtOnceSettingsValue,
                hasMandatoryTutorialBeenShown: widget.gameSettings.hasMandatoryTutorialBeenShown,
                clueVersionSetting: clueVersionSettingsValue,
            )
          );
          return Future.value(false);
        },
        child: BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsFetched) {
              primaryAppColorSettingsValue = state.primaryColor;
              clueVersionSettingsValue = state.clueVersion;
              selectMultipleMarkingsAtOnceSettingsValue = state.selectMultipleMarkingsAtOnce;
            }
          },
          child: BlocBuilder<SettingsBloc, SettingsState> (
            builder: (context, state) {
              if (state is SettingsFetched) {
                return _showSettingsList(state);
              }
              else {
                return WidgetUtils.progressIndicator(Color(primaryAppColorSettingsValue));
              }
            },
          ),
        ),
      ),
    );
  }

  _showSettingsList(SettingsFetched state) {
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            onTap: () {
              _showColorPickerDialog();
            },
            title: const Text(
                "Primary color",
            ),
            trailing: SizedBox(
              height: 30,
              child: CircleAvatar(
                backgroundColor: Color(primaryAppColorSettingsValue),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            onTap: () {
              // Open dialog settings colour
              setState(() {
                selectMultipleMarkingsAtOnceSettingsValue = !selectMultipleMarkingsAtOnceSettingsValue;
              });
              _updateBlocState();
            },
            title: const Text(
              "Select multiple markings at once",
            ),
            subtitle: const Text(
            "If enabled, the dialog will not be dismissed after tapping on the first marking",
            ),
            trailing: Checkbox(
              fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                final c = Color(primaryAppColorSettingsValue);
                if (states.contains(MaterialState.disabled)) {
                  return c.withOpacity(.32);
                }
                return c;
              }),
              onChanged: (value) {
                setState(() {
                  selectMultipleMarkingsAtOnceSettingsValue = value ?? false;
                });
                _updateBlocState();
              },
              value: selectMultipleMarkingsAtOnceSettingsValue,
            ),
          ),
        ),
        ListTile(
          onTap: _showClueVersionSelectDialog,
          title: const Text(
            "Clue version"
          ),
          trailing: Text(
            ConstantUtils.clueVersionSettingDisplayNameMap[clueVersionSettingsValue]!,
            style: TextStyle(
              color: Color(primaryAppColorSettingsValue),
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  _showClueVersionSelectDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState2) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text(
                "Select version",
                style: TextStyle(
                    color: Color(primaryAppColorSettingsValue)
                ),
              ),
              content: SizedBox(
                width: ScreenUtils.getScreenWidth(context) / 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ConstantUtils.clueVersionOptions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final version = ConstantUtils.clueVersionOptions[index];
                    return ListTile(
                      title: Text(ConstantUtils.clueVersionSettingDisplayNameMap[version]!,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      leading: Transform.scale(
                        scale: 1.25,
                        child: Checkbox(
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                            final c = Color(primaryAppColorSettingsValue);
                            if (states.contains(MaterialState.disabled)) {
                              return c.withOpacity(.32);
                            }
                            return c;
                          }),
                          value: clueVersionSettingsValue.name == version.name,
                          shape: const CircleBorder(),
                          onChanged: (bool? value) {
                            if (value ?? false) {
                              setState(() {
                                clueVersionSettingsValue = version;
                              });
                              setState2(() {
                                clueVersionSettingsValue = version;
                              });
                              _updateBlocState();
                            }
                          },
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          clueVersionSettingsValue = version;
                        });
                        setState2(() {
                          clueVersionSettingsValue = version;
                        });
                        _updateBlocState();
                      },
                    );
                  },
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(primaryAppColorSettingsValue)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Go back"),
                ),
              ],
            );
          });
        }
    );
  }

  _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
              'Select color',
            style: TextStyle(
              color: Color(primaryAppColorSettingsValue)
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Color(primaryAppColorSettingsValue),
              onColorChanged: (color) {
                lastSelectedColorValue = color;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(primaryAppColorSettingsValue)),
              ),
              onPressed: () {
                setState(() {
                  primaryAppColorSettingsValue = ConstantUtils.primaryAppColor.value;
                });
                _updateBlocState();
                Navigator.of(context).pop();
              },
              child: const Text("Reset to default"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(primaryAppColorSettingsValue)),
              ),
              onPressed: () {
                setState(() {
                  primaryAppColorSettingsValue = lastSelectedColorValue.value;
                });
                _updateBlocState();
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      }
    );
  }

  _updateBlocState() {
    settingsGameBloc.add(
        SettingsUpdated(
            primaryColor: primaryAppColorSettingsValue,
            selectMultipleMarkingsAtOnce: selectMultipleMarkingsAtOnceSettingsValue,
            selectedClueVersion: clueVersionSettingsValue,
        )
    );
  }
}