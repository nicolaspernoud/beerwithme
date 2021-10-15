import 'package:flutter/material.dart';
import 'package:frontend/models/brand.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/crud.dart';
import 'package:frontend/models/item.dart';

import '../globals.dart';
import '../i18n.dart';
import 'new_item.dart';
import 'settings.dart';

class Items extends StatefulWidget {
  final Crud crud;

  final String title;

  const Items({Key? key, required this.crud, required this.title})
      : super(key: key);

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  late Future<List<Item>> items;
  String filter = "";

  @override
  void initState() {
    super.initState();
    if (App().hasToken) {
      items = widget.crud.ReadAll();
    } else {
      WidgetsBinding.instance?.addPostFrameCallback(openSettings);
    }
    ;
  }

  void openSettings(_) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(MyLocalizations.of(context)!.tr("settings")),
        content: Container(
          child: const settingsField(),
          height: 150,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    setState(() {
      hasRoleOrOpenSettings(_);
    });
  }

  void hasRoleOrOpenSettings(_) {
    if (App().hasToken) {
      items = widget.crud.ReadAll();
    } else {
      openSettings(_);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/icon.png',
                fit: BoxFit.contain,
                height: 40,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return Settings(crud: APICrud<Category>());
                  }));
                  setState(() {
                    hasRoleOrOpenSettings(null);
                  });
                })
          ],
        ),
        body: (App().hasToken)
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<Item>>(
                  future: items,
                  builder: (context, snapshot) {
                    Widget child;
                    if (snapshot.hasData) {
                      var ts = snapshot.data!
                          .where((element) => element.name.contains(filter));
                      child = RefreshIndicator(
                        color: Colors.amberAccent,
                        onRefresh: () {
                          items = widget.crud.ReadAll();
                          setState(() {});
                          return items;
                        },
                        child: ListView.builder(
                          itemBuilder: (ctx, i) {
                            return Card(
                                child: InkWell(
                              splashColor: Colors.amber.withAlpha(30),
                              onTap: () {
                                _edit(ts.elementAt(i));
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                      leading: Icon(Icons.sports_bar),
                                      title: Text(ts.elementAt(i).name),
                                      subtitle: Text(
                                        ts.elementAt(i).description,
                                        maxLines: 2,
                                      ))
                                ],
                              ),
                            ));
                          },
                          itemCount: ts.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      child = Text(
                          MyLocalizations.of(context)!.tr("try_new_token"));
                    } else {
                      child = const CircularProgressIndicator();
                    }
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: child,
                    );
                  },
                ),
              ))
            : null,
        bottomNavigationBar: BottomAppBar(
            child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _edit(Item(
                      id: 0,
                      category_id: 1,
                      brand_id: 1,
                      name: "",
                      description: "",
                      time: DateTime.now(),
                    ));
                  }),
              Text(MyLocalizations.of(context)!.tr("create_item")),
              Expanded(
                child: Container(
                  height: 50,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.search),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      initialValue: "",
                      decoration: new InputDecoration(
                          labelText: MyLocalizations.of(context)!.tr("search")),
                      // The validator receives the text that the user has entered.
                      onChanged: (value) {
                        filter = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        )));
  }

  Future<void> _edit(t) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return NewEditItem(
          crud: APICrud<Item>(),
          categoriesCrud: APICrud<Category>(),
          brandsCrud: APICrud<Brand>(),
          item: t);
    }));
    setState(() {
      items = widget.crud.ReadAll();
    });
  }
}

String formatTime(DateTime d) {
  return "${d.year.toString()}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";
}
