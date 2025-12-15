import 'package:flutter/material.dart';
import 'package:beerwithme/components/new_brand.dart';
import 'package:beerwithme/models/brand.dart';
import 'package:beerwithme/models/crud.dart';

import '../i18n.dart';

class Brands extends StatefulWidget {
  final Crud crud;
  const Brands({super.key, required this.crud});

  @override
  BrandsState createState() => BrandsState();
}

class BrandsState extends State<Brands> {
  late Future<List<Brand>> brands;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    brands = widget.crud.read();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(MyLocalizations.of(context)!.tr("brands"))),
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
                Row(
                  children: <Widget>[
                    const Icon(Icons.search),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          controller: searchController,
                          onChanged: (text) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: MyLocalizations.of(
                              context,
                            )!.tr("search"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                FutureBuilder<List<Brand>>(
                  future: brands,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          ...snapshot.data!
                              .where(
                                (element) =>
                                    element.name.toLowerCase().contains(
                                      searchController.text.toLowerCase(),
                                    ),
                              )
                              .map(
                                (a) => Card(
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
                                  ),
                                ),
                              ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              color: Colors.blue,
                              onPressed: () {
                                _editBrand(
                                  Brand(id: 0, name: "", description: ""),
                                );
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editBrand(Brand b) async {
    var br = await Navigator.push(
      context,
      MaterialPageRoute<Brand>(
        builder: (BuildContext context) {
          return NewEditBrand(crud: APICrud<Brand>(), brand: b);
        },
      ),
    );
    setState(() {
      searchController.text = br!.name;
      brands = widget.crud.read();
    });
  }
}
