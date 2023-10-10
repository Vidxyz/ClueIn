import 'dart:async';

import 'package:cluein_app/src/views/home_page/home_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {

  const SplashPage({Key? key}): super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashPage());
  }

  @override
  State<StatefulWidget> createState() {
    return SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox.expand(
          child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/icon.png"),
                    fit: BoxFit.contain
                ),
                color: Colors.white
            ),
          ),
        )
    );
  }

  void startTimer() {
    Timer(const Duration(seconds: 1, milliseconds: 500), () {
      WidgetsFlutterBinding.ensureInitialized();
      Navigator.of(context).pushReplacement(HomePageView.route());
    });
  }

}