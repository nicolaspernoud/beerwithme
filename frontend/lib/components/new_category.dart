import 'package:flutter/material.dart';
import 'package:frontend/models/crud.dart';
import 'package:frontend/models/category.dart';

import '../i18n.dart';

class NewEditCategory extends StatefulWidget {
  final Crud crud;
  final Category category;
  const NewEditCategory({Key? key, required this.crud, required this.category})
      : super(key: key);

  @override
  _NewEditCategoryState createState() => _NewEditCategoryState();
}

class _NewEditCategoryState extends State<NewEditCategory> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        appBar: AppBar(
          title: widget.category.id > 0
              ? Text(MyLocalizations.of(context)!.tr("edit_category"))
              : Text(MyLocalizations.of(context)!.tr("new_category")),
          actions: widget.category.id > 0
              ? [
                  IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () async {
                        await widget.crud.delete(widget.category.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(MyLocalizations.of(context)!
                                .tr("category_deleted"))));
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
                    initialValue: widget.category.name,
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
                    onChanged: (value) {
                      widget.category.name = value;
                    },
                  ),
                  TextFormField(
                    initialValue: widget.category.description,
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
                      widget.category.description = value;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          var msg = MyLocalizations.of(context)!
                              .tr("category_created");
                          try {
                            if (widget.category.id > 0) {
                              await widget.crud.update(widget.category);
                            } else {
                              await widget.crud.create(widget.category);
                            }
                            // Do nothing on TypeError as Create respond with a null id
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
                        child: Text(MyLocalizations.of(context)!.tr("submit")),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
