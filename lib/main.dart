import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/views/home_page/home_page.dart';
import 'package:cluein_app/src/views/shared_components/ads/bloc/ad_bloc.dart';
import 'package:cluein_app/src/views/splash/splash_page.dart';
import 'package:cluein_app/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SembastRepository>(create: (context) => SembastRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AdBloc>(
              create: (context) => AdBloc()
          ),
        ],
        child: AppView(),
        // child: renderAppView(),
      ),
    );
  }

  // Use this to restrict web app width - unused right now because of problems with tutorial screen
  renderAppView() {
    if (kIsWeb) {
      return Center(
        child: ClipRect(
          child: SizedBox(
              width: ConstantUtils.WEB_APP_MAX_WIDTH,
              child: AppView()
          ),
        ),
      );
    }
    else {
      return AppView();
    }
  }
}

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  void initState() {
    super.initState();

    var hack = RepositoryProvider.of<SembastRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ClueIn",
      theme: appTheme,
      // darkTheme: darkTheme,
      // routes: {
      //   '/login': (context) => const LoginPage(),
      //   '/home': (context) => const HomePage(),
      //   '/create-account': (context) => const CreateAccountPage(),
      //   '/reset-password': (context) => const ResetPasswordPage(),
      //   '/complete-profile': (context) => const CompleteProfilePage(),
      // },
      navigatorKey: _navigatorKey,
      onGenerateRoute: (_) {
        return SplashPage.route();
      },
    );
  }
}