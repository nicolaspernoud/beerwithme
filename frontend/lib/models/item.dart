import 'package:equatable/equatable.dart';

import 'crud.dart';

class Item extends Serialisable with EquatableMixin {
  int categoryId;
  int brandId;
  String name;
  double alcohol;
  int ibu;
  String description;
  int rating;
  DateTime time;

  Item({
    required id,
    required this.categoryId,
    required this.brandId,
    required this.name,
    required this.alcohol,
    required this.ibu,
    required this.description,
    required this.rating,
    required this.time,
  }) : super(id: id);

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'category_id': categoryId,
      'brand_id': brandId,
      'name': name,
      'alcohol': alcohol,
      'ibu': ibu,
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
      ibu: json['ibu'],
      description: json['description'],
      rating: json['rating'],
      time:
          json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      categoryId,
      brandId,
      name,
      alcohol,
      ibu,
      description,
      rating,
      time
    ];
  }

  @override
  bool get stringify => true;
}
