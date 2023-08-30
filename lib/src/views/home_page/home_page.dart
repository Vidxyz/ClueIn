import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/create_new_game/create_new_game.dart';
import 'package:flutter/material.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _appIcon(),
              WidgetUtils.spacer(5),
              _appText(),
              WidgetUtils.spacer(15),
              _actionButton("New Game"),
              WidgetUtils.spacer(5),
              _actionButton("Load Game"),
              WidgetUtils.spacer(5),
              _actionButton("Settings"),
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
    return ElevatedButton(
        onPressed: () {
          switch (title) {
            case "New Game":
              _goToCreateNewGamePage();
              break;
            default:
              break;
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
        ),
        child: Text(title),
    );
  }

  _appText() {
    return const Center(
      child: Text(
        "ClueIn",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
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

}