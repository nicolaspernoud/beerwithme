import 'package:equatable/equatable.dart';

import 'crud.dart';

class Item extends Serialisable with EquatableMixin {
  int categoryId;
  int brandId;
  String name;
  double alcohol;
  String barcode;
  String description;
  int rating;
  DateTime time;
  String? brandName;

  Item(
      {required id,
      required this.categoryId,
      required this.brandId,
      required this.name,
      required this.alcohol,
      required this.barcode,
      required this.description,
      required this.rating,
      required this.time,
      this.brandName})
      : super(id: id);

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'category_id': categoryId,
      'brand_id': brandId,
      'name': name,
      'alcohol': alcohol,
      'barcode': barcode,
      'description': description,
      'rating': rating,
      'time': time.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'],
        categoryId: json['category_id'],
        brandId: json['brand_id'],
        name: json['name'],
        alcohol: json['alcohol'],
        barcode: json['barcode'],
        description: json['description'],
        rating: json['rating'],
        time: json['time'] != null
            ? DateTime.parse(json['time'])
            : DateTime.now(),
        brandName: json['brand_name']);
  }

  @override
  List<Object> get props {
    return [
      id,
      categoryId,
      brandId,
      name,
      alcohol,
      barcode,
      description,
      rating,
      time
    ];
  }

  @override
  bool get stringify => true;
}
