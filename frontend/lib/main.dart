import 'package:flutter/material.dart';
import 'package:beerwithme/globals.dart';
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
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beer with me!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber,
          elevation: 4,
          shadowColor: Theme.of(context).shadowColor,
        ),
      ),
      home: const MyHomePage(title: 'Beer with me!'),
      localizationsDelegates: const [
        MyLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('fr', '')],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Items(crud: APICrud<Item>(), title: widget.title);
  }
}
