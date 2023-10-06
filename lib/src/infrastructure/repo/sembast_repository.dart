import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsRepository {

  late SharedPreferences prefs;

  init() async {
    prefs = await SharedPreferences.getInstance();
  }

  SharedPrefsRepository() {
    init();
  }
}