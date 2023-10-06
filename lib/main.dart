import 'package:cluein_app/src/infrastructure/repo/sembast_repository.dart';
import 'package:cluein_app/src/views/home_page/home_page.dart';
import 'package:cluein_app/src/views/shared_components/ads/bloc/ad_bloc.dart';
import 'package:cluein_app/theme.dart';
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
        RepositoryProvider<SharedPrefsRepository>(create: (context) => SharedPrefsRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AdBloc>(
              create: (context) => AdBloc()
          ),
        ],
        child: AppView(),
      ),
    );
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
      home: const HomePage(),
    );
  }
}