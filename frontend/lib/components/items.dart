import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:frontend/components/star_rating.dart';
import 'package:frontend/models/brand.dart';
import 'package:frontend/models/category.dart' as category;
import 'package:frontend/models/crud.dart';
import 'package:frontend/models/item.dart';
import 'package:easy_debounce/easy_debounce.dart';

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
      items = widget.crud.read();
    } else {
      WidgetsBinding.instance?.addPostFrameCallback(openSettings);
    }
  }

  void openSettings(_) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(MyLocalizations.of(context)!.tr("settings")),
        content: const SizedBox(
          child: SettingsField(),
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
                'assets/icon/icon.png',
                fit: BoxFit.contain,
                height: 40,
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
                                    leading: const Icon(Icons.sports_bar),
                                    title: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: StarRating(
                                            rating: itms.elementAt(i).rating,
                                            onRatingChanged: (rating) {
                                              return;
                                            },
                                            color: Colors.amber,
                                            alterable: false,
                                          ),
                                        ),
                                        Text(itms.elementAt(i).name),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        itms.elementAt(i).description,
                                        maxLines: 2,
                                      ),
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
                  SizedBox(
                    width: 160,
                    child: TextFormField(
                        key: Key(filter),
                        initialValue: filter,
                        decoration: InputDecoration(
                            labelText:
                                MyLocalizations.of(context)!.tr("search")),
                        // The validator receives the text that the user has entered.
                        onChanged: (value) {
                          filter = value;
                          EasyDebounce.debounce('read-items-filter',
                              const Duration(milliseconds: 250), () {
                            items = widget.crud.read("name=$filter&barcode=");
                            setState(() {});
                          });
                        },
                        onTap: () {
                          items = widget.crud.read("name=$filter&barcode=");
                          setState(() {});
                        }),
                  ),
                  if (!kIsWeb)
                    IconButton(
                        onPressed: () async {
                          var barcode = await FlutterBarcodeScanner.scanBarcode(
                              "#ffc107",
                              MyLocalizations.of(context)!.tr("cancel"),
                              true,
                              ScanMode.BARCODE);
                          EasyDebounce.debounce('read-items-filter',
                              const Duration(milliseconds: 250), () {
                            items = widget.crud.read("name=&barcode=$barcode");
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.qr_code_scanner))
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
          categoriesCrud: APICrud<category.Category>(),
          brandsCrud: APICrud<Brand>(),
          item: t);
    }));
    filter = "";
    items = widget.crud.read();
    setState(() {});
  }
}

String formatTime(DateTime d) {
  return "${d.year.toString()}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";
}
