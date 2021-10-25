import 'package:flutter/material.dart';
import 'package:frontend/components/new_category.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/crud.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import '../globals.dart';
import '../i18n.dart';

class Settings extends StatefulWidget {
  final Crud crud;
  const Settings({Key? key, required this.crud}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late Future<List<Category>> categories;
  static const _url =
      'https://github.com/nicolaspernoud/beerwithme/releases/latest';
  @override
  void initState() {
    super.initState();
    categories = widget.crud.read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(MyLocalizations.of(context)!.tr("settings")),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const SettingsField(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ElevatedButton(
                  onPressed: () async {
                    await canLaunch(_url)
                        ? await launch(_url)
                        : throw 'Could not launch $_url';
                  },
                  child: Text(
                      MyLocalizations.of(context)!.tr("get_latest_release")),
                ),
              ),
              ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      MyLocalizations.of(context)!.tr("categories"),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                FutureBuilder<List<Category>>(
                  future: categories,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          ...snapshot.data!
                              .map((a) => Card(
                                      child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      _editCategory(a);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: const Icon(Icons.label),
                                          title: Text(a.name),
                                          subtitle: Text(a.description),
                                        ),
                                      ],
                                    ),
                                  )))
                              .toList(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              color: Colors.blue,
                              onPressed: () {
                                _editCategory(
                                    Category(id: 0, name: "", description: ""));
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    // By default, show a loading spinner.
                    return const Center(child: CircularProgressIndicator());
                  },
                )
              ],
            ],
          ),
        )));
  }

  Future<void> _editCategory(Category c) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return NewEditCategory(crud: APICrud<Category>(), category: c);
    }));
    setState(() {
      categories = widget.crud.read();
    });
  }
}

class SettingsField extends StatelessWidget {
  const SettingsField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!kIsWeb || kDebugMode)
          TextFormField(
            initialValue: App().prefs.getString("hostname"),
            decoration: InputDecoration(
                labelText: MyLocalizations.of(context)!.tr("hostname")),
            onChanged: (text) {
              App().prefs.setString("hostname", text);
            },
            key: const Key("hostnameField"),
          ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: App().prefs.getString("token"),
          decoration: InputDecoration(
              labelText: MyLocalizations.of(context)!.tr("token")),
          onChanged: (text) {
            App().prefs.setString("token", text);
          },
          key: const Key("tokenField"),
        ),
      ],
    );
  }
}
