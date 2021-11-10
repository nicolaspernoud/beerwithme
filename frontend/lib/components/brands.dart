import 'package:flutter/material.dart';
import 'package:frontend/components/new_brand.dart';
import 'package:frontend/models/brand.dart';
import 'package:frontend/models/crud.dart';

import '../i18n.dart';

class Brands extends StatefulWidget {
  final Crud crud;
  const Brands({Key? key, required this.crud}) : super(key: key);

  @override
  _BrandsState createState() => _BrandsState();
}

class _BrandsState extends State<Brands> {
  late Future<List<Brand>> brands;
  String filter = "";

  @override
  void initState() {
    super.initState();
    brands = widget.crud.read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(MyLocalizations.of(context)!.tr("brands")),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      MyLocalizations.of(context)!.tr("brands"),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Row(children: <Widget>[
                  const Icon(Icons.search),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        initialValue: filter,
                        decoration: InputDecoration(
                            labelText:
                                MyLocalizations.of(context)!.tr("search")),
                        onChanged: (value) {
                          filter = value;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ]),
                FutureBuilder<List<Brand>>(
                  future: brands,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          ...snapshot.data!
                              .where((element) => element.name
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()))
                              .map((a) => Card(
                                      child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.pop(context, a);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _editBrand(a);
                                            },
                                          ),
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
                                _editBrand(
                                    Brand(id: 0, name: "", description: ""));
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

  Future<void> _editBrand(Brand b) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return NewEditBrand(crud: APICrud<Brand>(), brand: b);
    }));
    setState(() {
      brands = widget.crud.read();
    });
  }
}
