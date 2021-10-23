import 'package:flutter/material.dart';
import 'package:frontend/globals.dart';
import 'components/items.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'i18n.dart';
import 'models/crud.dart';
import 'models/item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await App().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beer with me!',
      theme: ThemeData(primarySwatch: Colors.yellow),
      home: const MyHomePage(title: 'Beer with me!'),
      localizationsDelegates: const [
        MyLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Items(crud: APICrud<Item>(), title: widget.title);
  }
}
