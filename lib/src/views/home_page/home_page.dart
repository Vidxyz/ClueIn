import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/about/about_page.dart';
import 'package:cluein_app/src/views/create_new_game/create_new_game.dart';
import 'package:cluein_app/src/views/load_game/load_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State createState() {
    return HomePageState();
  }

}

class HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();

    var hack = RepositoryProvider.of<SembastRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _appIcon(),
              // WidgetUtils.spacer(10),
              // _appText(),
              WidgetUtils.spacer(25),
              _actionButton("New Game"),
              WidgetUtils.spacer(5),
              _actionButton("Load Game"),
              // todo - post MVP - include settings menu with different CLUE game flavours
              // WidgetUtils.spacer(5),
              // _actionButton("Settings"),
              WidgetUtils.spacer(5),
              _actionButton("About"),
              WidgetUtils.spacer(5),
            ],
          ),
        ),
      ),
    );
  }

  _actionButton(String title) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
          onPressed: () {
            switch (title) {
              case "Load Game":
                _goToLoadGamePage();
                break;
              case "New Game":
                _goToCreateNewGamePage();
                break;
              case "About":
                _goToAboutPage();
                break;
              default:
                break;
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(ConstantUtils.primaryAppColor),
          ),
          child: Text(title),
      ),
    );
  }

  _appText() {
    return const Center(
      child: Text(
        "ClueIn",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: ConstantUtils.primaryAppColor
        ),
      ),
    );
  }

  _appIcon() {
    return Center(
      child: CircleAvatar(
        radius: 100,
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage("assets/icon.png")
              ),
            ),
          ),
        ),
      ),
    );
  }

  _goToCreateNewGamePage() {
    Navigator.push(
        context,
        CreateNewGameView.route()
    );
  }

  _goToLoadGamePage() {
    Navigator.push(
        context,
        LoadGameView.route()
    );
  }

  _goToAboutPage() {
    Navigator.push(
        context,
        AboutPage.route()
    );
  }

}