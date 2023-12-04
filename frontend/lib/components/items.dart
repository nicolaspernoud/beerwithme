import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/star_rating.dart';
import 'package:frontend/models/brand.dart';
import 'package:frontend/models/category.dart' as category;
import 'package:frontend/models/crud.dart';
import 'package:frontend/models/item.dart';

import '../globals.dart';
import '../i18n.dart';
import 'new_item.dart';
import 'scanner.dart';
import 'settings.dart';

class Items extends StatefulWidget {
  final Crud crud;

  final String title;

  const Items({super.key, required this.crud, required this.title});

  @override
  ItemsState createState() => ItemsState();
}

class ItemsState extends State<Items> {
  late Future<List<Item>> items;
  String _filter = "";

  @override
  void initState() {
    super.initState();
    if (App().hasToken) {
      items = widget.crud.read();
    } else {
      WidgetsBinding.instance.addPostFrameCallback(openSettings);
    }
  }

  void openSettings(_) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(MyLocalizations.of(context)!.tr("settings")),
        content: const SizedBox(
          height: 150,
          child: SettingsField(),
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
      hasTokenOrOpenSettings(_);
    });
  }

  void hasTokenOrOpenSettings(_) {
    if (App().hasToken) {
      items = widget.crud.read();
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
                'assets/icon/icon_foreground.png',
                fit: BoxFit.contain,
                height: 60,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return Settings(crud: APICrud<category.Category>());
                  }));
                  setState(() {
                    hasTokenOrOpenSettings(null);
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
                      var itms = snapshot.data!;
                      child = ListView.builder(
                        itemBuilder: (ctx, i) {
                          return Card(
                              child: InkWell(
                            splashColor: Colors.amber.withAlpha(30),
                            onTap: () {
                              _edit(itms.elementAt(i));
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                    leading: SizedBox(
                                      width: 75,
                                      child: StarRating(
                                        rating: itms.elementAt(i).rating,
                                        onRatingChanged: (rating) {
                                          return;
                                        },
                                        color: Colors.amber,
                                        alterable: false,
                                      ),
                                    ),
                                    title: Text(
                                        "${itms.elementAt(i).name} - ${itms.elementAt(i).brandName!}"),
                                    subtitle: Text(
                                      itms.elementAt(i).description,
                                      maxLines: 2,
                                    ))
                              ],
                            ),
                          ));
                        },
                        itemCount: itms.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                      );
                    } else if (snapshot.hasError) {
                      child = Text(
                          MyLocalizations.of(context)!.tr("try_new_token"));
                    } else {
                      child = const CircularProgressIndicator();
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: child,
                    );
                  },
                ),
              ))
            : null,
        bottomNavigationBar: StickyBottomAppBar(
          child: BottomAppBar(
              child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _edit(Item(
                        id: 0,
                        categoryId: 1,
                        brandId: 1,
                        name: "",
                        alcohol: 5.0,
                        barcode: "",
                        description: "",
                        rating: 2,
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
                    const Icon(Icons.search),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 160,
                        child: TextFormField(
                            initialValue: _filter,
                            decoration: InputDecoration(
                                labelText:
                                    MyLocalizations.of(context)!.tr("search")),
                            // The validator receives the text that the user has entered.
                            onChanged: (value) {
                              _filter = value;
                              setState(() {
                                items =
                                    widget.crud.read("name=$_filter&barcode=");
                              });
                            },
                            onTap: () {
                              items =
                                  widget.crud.read("name=$_filter&barcode=");
                              setState(() {});
                            }),
                      ),
                    ),
                    if (!kIsWeb)
                      IconButton(
                          onPressed: () async {
                            final barcode = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BarcodeScanner()),
                            );
                            if (barcode != null) {
                              setState(() {
                                items =
                                    widget.crud.read("name=&barcode=$barcode");
                              });
                            }
                          },
                          icon: const Icon(Icons.qr_code_scanner))
                  ],
                ),
              ],
            ),
          )),
        ));
  }

  Future<void> _edit(t) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return NewEditItem(
          crud: APICrud<Item>(),
          categoriesCrud: APICrud<category.Category>(),
          brandsCrud: APICrud<Brand>(),
          item: t);
    }));
    setState(() {
      items = widget.crud.read("name=$_filter&barcode=");
    });
  }
}

String formatTime(DateTime d) {
  return "${d.year.toString()}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";
}

class StickyBottomAppBar extends StatelessWidget {
  final BottomAppBar child;
  const StickyBottomAppBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
      child: child,
    );
  }
}
