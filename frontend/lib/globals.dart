import 'package:shared_preferences/shared_preferences.dart';

class App {
  late SharedPreferences prefs;
  App._privateConstructor();

  static final App _instance = App._privateConstructor();

  factory App() {
    return _instance;
  }

  bool get hasToken {
    return prefs.getString("token") != null;
  }

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }
}
