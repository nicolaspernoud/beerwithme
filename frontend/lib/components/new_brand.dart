import 'package:flutter/material.dart';
import 'package:frontend/models/crud.dart';
import 'package:frontend/models/brand.dart';

import '../i18n.dart';

class NewEditBrand extends StatefulWidget {
  final Crud crud;
  final Brand brand;
  const NewEditBrand({super.key, required this.crud, required this.brand});

  @override
  NewEditBrandState createState() => NewEditBrandState();
}

class NewEditBrandState extends State<NewEditBrand> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        appBar: AppBar(
          title: widget.brand.id > 0
              ? Text(MyLocalizations.of(context)!.tr("edit_brand"))
              : Text(MyLocalizations.of(context)!.tr("new_brand")),
          actions: widget.brand.id > 0
              ? [
                  IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () async {
                        await widget.crud.delete(widget.brand.id);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(MyLocalizations.of(context)!
                                .tr("brand_deleted"))));
                      })
                ]
              : null,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: widget.brand.name,
                    decoration: InputDecoration(
                        labelText: MyLocalizations.of(context)!.tr("title")),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return MyLocalizations.of(context)!
                            .tr("please_enter_some_text");
                      }
                      return null;
                    },
                    onChanged: (value) {
                      widget.brand.name = value;
                    },
                  ),
                  TextFormField(
                    initialValue: widget.brand.description,
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
                    onChanged: (value) {
                      widget.brand.description = value;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          var msg =
                              MyLocalizations.of(context)!.tr("brand_created");
                          try {
                            if (widget.brand.id > 0) {
                              await widget.crud.update(widget.brand);
                            } else {
                              await widget.crud.create(widget.brand);
                            }
                            // Do nothing on TypeError as Create respond with a null id
                          } catch (e) {
                            msg = e.toString();
                          }
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                          Navigator.pop(context, widget.brand);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(MyLocalizations.of(context)!.tr("submit")),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
