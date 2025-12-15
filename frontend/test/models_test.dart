// Import the test package and Counter class
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:beerwithme/models/brand.dart';
import 'package:beerwithme/models/category.dart';
import 'package:beerwithme/models/item.dart';

void main() {
  group('Serialization', () {
    test(
      'Converting an Category to json an retrieving it should give the same Category',
      () async {
        final Category c1 = Category(
          id: 1,
          name: "test name",
          description: "test description",
        );
        final c1Json = jsonEncode(c1.toJson());
        final c2 = Category.fromJson(json.decode(c1Json));
        expect(c1, c2);
      },
    );

    test(
      'Converting a Item to json an retrieving it should give the same Item',
      () async {
        final Item i1 = Item(
          id: 1,
          categoryId: 10,
          brandId: 20,
          name: "a name",
          alcohol: 5.0,
          barcode: "a barcode",
          description: "a description",
          rating: 5,
          time: DateTime.now(),
        );
        final a1Json = jsonEncode(i1.toJson());
        final i2 = Item.fromJson(json.decode(a1Json));
        expect(i1, i2);
      },
    );

    test(
      'Converting a Brand to json an retrieving it should give the same Brand',
      () async {
        final Brand b1 = Brand(
          id: 1,
          name: "test name",
          description: "test description",
        );
        final b1Json = jsonEncode(b1.toJson());
        final b2 = Brand.fromJson(json.decode(b1Json));
        expect(b1, b2);
      },
    );
  });
}
