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
import 'star_rating.dart';

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
  // ignore: constant_identifier_names
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
      itemWithComments = widget.crud.readOne(widget.item.id);
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
          headers: <String, String>{'Authorization': "Bearer " + token},
          body: img);
      if (response.statusCode != 200) {
        throw Exception(response.body.toString());
      }
    } else {
      await http.delete(
        Uri.parse('$hostname/items/photos/${id.toString()}'),
        headers: <String, String>{'Authorization': "Bearer " + token},
      );
    }
  }

  _imgFromServer(int id) async {
    final response = await http.get(
      Uri.parse('$hostname/items/photos/${id.toString()}'),
      headers: <String, String>{'Authorization': "Bearer " + token},
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
                        await widget.crud.delete(widget.item.id);
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
                TextFormField(
                  maxLength: 75,
                  decoration: InputDecoration(
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
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                          '${MyLocalizations.of(context)!.tr("alcohol")} (${widget.item.alcohol.toStringAsFixed(1)})'),
                    ),
                    Expanded(
                      child: Slider(
                        value: widget.item.alcohol,
                        min: 0,
                        max: 100,
                        divisions: 1000,
                        label: widget.item.alcohol.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            widget.item.alcohol =
                                double.parse(value.toStringAsFixed(1));
                          });
                        },
                      ),
                    ),
                  ],
                ),
                CategoriesDropDown(
                  crud: widget.categoriesCrud,
                  callback: (val) => widget.item.categoryId = val,
                  initialIndex: widget.item.categoryId,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: BrandsDropDown(
                    crud: widget.brandsCrud,
                    callback: (val) => widget.item.brandId = val,
                    initialIndex: widget.item.brandId,
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                          '${MyLocalizations.of(context)!.tr("ibu")} (${widget.item.ibu.round().toString()})'),
                    ),
                    Expanded(
                      child: Slider(
                        value: widget.item.ibu.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: widget.item.ibu.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            widget.item.ibu = value.round();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
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
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(MyLocalizations.of(context)!.tr("rating")),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: StarRating(
                        rating: widget.item.rating,
                        onRatingChanged: (rating) =>
                            setState(() => widget.item.rating = rating.round()),
                        color: Colors.amberAccent,
                        alterable: true,
                      ),
                    )
                  ],
                ),
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
                                icon: const Icon(Icons.clear))
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return IconButton(
                          onPressed: () {
                            _imgFromCamera();
                          },
                          icon: const Icon(Icons.camera_alt));
                    },
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: Center(
                        child: AnimatedSwitcher(
                          switchInCurve: const Interval(
                            0.5,
                            1,
                            curve: Curves.linear,
                          ),
                          switchOutCurve: const Interval(
                            0,
                            0.5,
                            curve: Curves.linear,
                          ).flipped,
                          duration: const Duration(milliseconds: 500),
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
                                          await widget.crud.update(widget.item);
                                          await _imgToServer(widget.item.id);
                                        } else {
                                          var t = await widget.crud
                                              .create(widget.item);
                                          await _imgToServer(t.id);
                                        }
                                      } catch (e) {
                                        msg = e.toString();
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(MyLocalizations.of(context)!
                                        .tr("submit")),
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                    Text(formatTime(widget.item.time)),
                  ],
                ),
              ],
            ),
          ),
        )));
  }
}

typedef IntCallback = void Function(int val);

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
    categories = widget.crud.read();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<category.Category>>(
        future: categories,
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
                SizedBox(
                    width: 60,
                    child: Text(MyLocalizations.of(context)!.tr("category"))),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: 150,
                    child: DropdownButton<int>(
                      value: _index,
                      items: snapshot.data!.map((a) {
                        return DropdownMenuItem<int>(
                          value: a.id,
                          child: SizedBox(
                            width: 125,
                            child: Text(
                              a.name,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                  ),
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
    brands = widget.crud.read();
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
                    SizedBox(
                        width: 60,
                        child: Text(MyLocalizations.of(context)!.tr("brand"))),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: SizedBox(
                        width: 150,
                        child: DropdownButton<int>(
                          value: _index,
                          items: snapshot.data!.map((a) {
                            return DropdownMenuItem<int>(
                              value: a.id,
                              child: SizedBox(
                                width: 125,
                                child: Text(
                                  a.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                      ),
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
      brands = widget.crud.read();
    });
  }
}
