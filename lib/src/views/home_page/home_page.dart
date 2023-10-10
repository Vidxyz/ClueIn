import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:cluein_app/src/views/about/about_page.dart';
import 'package:cluein_app/src/views/create_new_game/create_new_game.dart';
import 'package:cluein_app/src/views/home_page/bloc/home_page_bloc.dart';
import 'package:cluein_app/src/views/home_page/bloc/home_page_event.dart';
import 'package:cluein_app/src/views/home_page/bloc/home_page_state.dart';
import 'package:cluein_app/src/views/load_game/load_game.dart';
import 'package:cluein_app/src/views/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageView extends StatefulWidget {

  const HomePageView({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => withBloc());
  }

  static Widget withBloc() => MultiBlocProvider(
    providers: [
      BlocProvider<HomePageBloc>(
          create: (context) => HomePageBloc(
            sembast: RepositoryProvider.of<SembastRepository>(context),
          )
      ),
    ],
    child: const HomePageView(),
  );

  @override
  State createState() {
    return HomePageViewState();
  }

}

class HomePageViewState extends State<HomePageView> {

  late Color primaryAppColorFromSetting;

  late HomePageBloc homePageBloc;

  @override
  void initState() {
    super.initState();

    homePageBloc = BlocProvider.of<HomePageBloc>(context);
    _fetchHomePageSettings();
  }

  _fetchHomePageSettings() {
    homePageBloc.add(const FetchHomePageSettings());
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<HomePageBloc, HomePageState>(
        listener: (context, state) {
          if (state is HomePageSettingsFetched) {
            primaryAppColorFromSetting = Color(state.primaryColor);
          }
        },
        child: BlocBuilder<HomePageBloc, HomePageState> (
          builder: (context, state) {
            if (state is HomePageSettingsFetched) {
              return Scaffold(
                body: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _appIcon(),
                        WidgetUtils.spacer(25),
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
            else {
              return WidgetUtils.progressIndicator();
            }
          },
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
              case "Settings":
                _goToSettingsPage();
                break;
              default:
                break;
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(primaryAppColorFromSetting),
          ),
          child: Text(title),
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
        CreateNewGameView.route(primaryAppColorFromSetting)
    ).then((value) => _fetchHomePageSettings());
  }

  _goToSettingsPage() {
    Navigator.push(
        context,
        SettingsView.route(primaryAppColorFromSetting)
    ).then((value) => _fetchHomePageSettings());
  }

  _goToLoadGamePage() {
    Navigator.push(
        context,
        LoadGameView.route(primaryAppColorFromSetting)
    ).then((value) => _fetchHomePageSettings());
  }

  _goToAboutPage() {
    Navigator.push(
        context,
        AboutPage.route(primaryAppColorFromSetting)
    ).then((value) => _fetchHomePageSettings());
  }

}