import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/brand.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/components/items.dart';
import 'package:frontend/models/category.dart' as category;
import 'package:frontend/models/crud.dart';
import 'package:frontend/models/item.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;

import '../globals.dart';
import '../i18n.dart';
import 'new_brand.dart';

class NewEditItem extends StatefulWidget {
  final Crud crud;
  final Crud categoriesCrud;
  final Crud brandsCrud;
  final Item item;
  const NewEditItem(
      {Key? key,
      required this.crud,
      required this.categoriesCrud,
      required this.brandsCrud,
      required this.item})
      : super(key: key);

  @override
  _NewEditItemState createState() => _NewEditItemState();
}

class _NewEditItemState extends State<NewEditItem> {
  static const JPG_IMAGE_QUALITY = 80;

  final _formKey = GlobalKey<FormState>();
  late Future<Item> itemWithComments;
  late bool isExisting;
  bool submitting = false;

  Future<Uint8List?>? imageBytes;
  String hostname = (App().prefs.getString("hostname") ?? "") + "/api";
  String token = App().prefs.getString("token") ?? "";

  @override
  void initState() {
    super.initState();
    isExisting = widget.item.id > 0;
    if (isExisting) {
      itemWithComments = widget.crud.ReadOne(widget.item.id);
      _imgFromServer(widget.item.id);
    } else {
      itemWithComments = Future<Item>.value(widget.item);
    }
  }

  _imgFromCamera() async {
    final temp = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: JPG_IMAGE_QUALITY,
        maxWidth: 1280);
    if (temp != null) {
      imageBytes = temp.readAsBytes();
      setState(() {});
    }
  }

  static Future<Uint8List> bakeOrientation(Uint8List img) async {
    final capturedImage = image.decodeImage(img);
    final orientedImage = image.bakeOrientation(capturedImage!);
    final encodedImage =
        image.encodeJpg(orientedImage, quality: JPG_IMAGE_QUALITY);
    return encodedImage as Uint8List;
  }

  Future<void> _imgToServer(int id) async {
    Uint8List? img = await imageBytes;
    if (imageBytes != null && img != null) {
      // Bake orientation on devices only as it is very slow and web does not support compute !!!
      if (!kIsWeb) {
        img = await compute(bakeOrientation, img);
      }
      final response = await http.post(
          Uri.parse('$hostname/items/photos/${id.toString()}'),
          headers: <String, String>{'X-TOKEN': token},
          body: img);
      if (response.statusCode != 200) {
        throw Exception(response.body.toString());
      }
    } else {
      await http.delete(
        Uri.parse('$hostname/items/photos/${id.toString()}'),
        headers: <String, String>{'X-TOKEN': token},
      );
    }
  }

  _imgFromServer(int id) async {
    final response = await http.get(
      Uri.parse('$hostname/items/photos/${id.toString()}'),
      headers: <String, String>{'X-TOKEN': token},
    );
    if (response.statusCode == 200) {
      imageBytes = Future.value(response.bodyBytes);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        appBar: AppBar(
          title: isExisting
              ? Text(MyLocalizations.of(context)!.tr("edit_item"))
              : Text(MyLocalizations.of(context)!.tr("new_item")),
          actions: (isExisting)
              ? [
                  IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () async {
                        await widget.crud.Delete(widget.item.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(MyLocalizations.of(context)!
                                .tr("item_deleted"))));
                      })
                ]
              : null,
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatTime(widget.item.time)),
                SizedBox(height: 10),
                TextFormField(
                  maxLength: 75,
                  decoration: new InputDecoration(
                      labelText: MyLocalizations.of(context)!.tr("name")),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return MyLocalizations.of(context)!
                          .tr("please_enter_some_text");
                    }
                    return null;
                  },
                  initialValue: widget.item.name,
                  onChanged: (value) {
                    widget.item.name = value;
                  },
                ),
                SizedBox(height: 10),
                CategoriesDropDown(
                  crud: widget.categoriesCrud,
                  callback: (val) => widget.item.category_id = val,
                  initialIndex: widget.item.category_id,
                ),
                SizedBox(height: 10),
                BrandsDropDown(
                  crud: widget.brandsCrud,
                  callback: (val) => widget.item.brand_id = val,
                  initialIndex: widget.item.brand_id,
                ),
                SizedBox(height: 10),
                TextFormField(
                  maxLines: 3,
                  decoration: new InputDecoration(
                      labelText:
                          MyLocalizations.of(context)!.tr("description")),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return MyLocalizations.of(context)!
                          .tr("please_enter_some_text");
                    }
                    return null;
                  },
                  initialValue: widget.item.description,
                  onChanged: (value) {
                    widget.item.description = value;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: FutureBuilder<Uint8List?>(
                    future: imageBytes,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                _imgFromCamera();
                              },
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.fitWidth,
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                  )),
                            ),
                            IconButton(
                                onPressed: () {
                                  imageBytes = Future.value(null);
                                  setState(() {});
                                },
                                icon: Icon(Icons.clear))
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return IconButton(
                          onPressed: () {
                            _imgFromCamera();
                          },
                          icon: Icon(Icons.camera_alt));
                    },
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 140,
                  height: 50,
                  child: Center(
                    child: AnimatedSwitcher(
                      switchInCurve: Interval(
                        0.5,
                        1,
                        curve: Curves.linear,
                      ),
                      switchOutCurve: Interval(
                        0,
                        0.5,
                        curve: Curves.linear,
                      ).flipped,
                      duration: Duration(milliseconds: 500),
                      child: !submitting
                          ? ElevatedButton(
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  submitting = true;
                                  setState(() {});
                                  var msg = MyLocalizations.of(context)!
                                      .tr("item_created");
                                  try {
                                    if (isExisting) {
                                      await widget.crud.Update(widget.item);
                                      await _imgToServer(widget.item.id);
                                    } else {
                                      var t =
                                          await widget.crud.Create(widget.item);
                                      await _imgToServer(t.id);
                                    }
                                  } catch (e) {
                                    msg = e.toString();
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg)),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                    MyLocalizations.of(context)!.tr("submit")),
                              ),
                            )
                          : Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}

typedef void IntCallback(int val);

class CategoriesDropDown extends StatefulWidget {
  final IntCallback callback;
  final Crud crud;
  final int initialIndex;
  const CategoriesDropDown({
    Key? key,
    required this.crud,
    required this.callback,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _CategoriesDropDownState createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
  late Future<List<category.Category>> categories;
  late int _index;

  @override
  void initState() {
    super.initState();
    categories = widget.crud.Read();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<category.Category>>(
        future: categories,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.length > 0) {
            // Check that index exists
            var minID = snapshot.data!.first.id;
            var indexExists = false;
            for (final e in snapshot.data!) {
              if (e.id < minID) minID = e.id;
              if (_index == e.id) {
                indexExists = true;
                break;
              }
              ;
            }
            if (!indexExists) _index = minID;
            widget.callback(_index);
            return Row(
              children: [
                Text(MyLocalizations.of(context)!.tr("category")),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _index,
                  items: snapshot.data!.map((a) {
                    return new DropdownMenuItem<int>(
                      value: a.id,
                      child: new Text(
                        a.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _index = value!;
                    });
                    widget.callback(value!);
                  },
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(MyLocalizations.of(context)!.tr("no_categories")),
          );
        });
  }
}

class BrandsDropDown extends StatefulWidget {
  final IntCallback callback;
  final Crud crud;
  final int initialIndex;
  const BrandsDropDown({
    Key? key,
    required this.crud,
    required this.callback,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _BrandsDropDownState createState() => _BrandsDropDownState();
}

class _BrandsDropDownState extends State<BrandsDropDown> {
  late Future<List<Brand>> brands;
  late int _index;

  @override
  void initState() {
    super.initState();
    brands = widget.crud.Read();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder<List<Brand>>(
            future: brands,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                // Check that index exists
                var minID = snapshot.data!.first.id;
                var indexExists = false;
                for (final e in snapshot.data!) {
                  if (e.id < minID) minID = e.id;
                  if (_index == e.id) {
                    indexExists = true;
                    break;
                  }
                }
                if (!indexExists) _index = minID;
                widget.callback(_index);
                return Row(
                  children: [
                    Text(MyLocalizations.of(context)!.tr("brands")),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _index,
                      items: snapshot.data!.map((a) {
                        return new DropdownMenuItem<int>(
                          value: a.id,
                          child: new Text(
                            a.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _index = value!;
                        });
                        widget.callback(value!);
                      },
                    ),
                    IconButton(
                        onPressed: () {
                          _editBrand(snapshot.data!
                              .singleWhere((element) => element.id == _index));
                        },
                        icon: const Icon(Icons.edit))
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(MyLocalizations.of(context)!.tr("no_brands")),
              );
            }),
        IconButton(
            onPressed: () {
              _editBrand(Brand(id: 0, name: "", description: ""));
            },
            icon: const Icon(Icons.add))
      ],
    );
  }

  Future<void> _editBrand(Brand c) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return NewEditBrand(crud: APICrud<Brand>(), brand: c);
    }));
    setState(() {
      brands = widget.crud.Read();
    });
  }
}
