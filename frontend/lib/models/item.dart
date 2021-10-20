import 'package:equatable/equatable.dart';

import 'crud.dart';

class Item extends Serialisable with EquatableMixin {
  int id;
  int category_id;
  int brand_id;
  String name;
  double alcohol;
  int ibu;
  String description;
  int rating;
  DateTime time;

  Item({
    required this.id,
    required this.category_id,
    required this.brand_id,
    required this.name,
    required this.alcohol,
    required this.ibu,
    required this.description,
    required this.rating,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'category_id': category_id,
      'brand_id': brand_id,
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
      category_id: json['category_id'],
      brand_id: json['brand_id'],
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
      category_id,
      brand_id,
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
