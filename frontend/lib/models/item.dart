import 'package:equatable/equatable.dart';

import 'crud.dart';

class Item extends Serialisable with EquatableMixin {
  int id;
  int category_id;
  int brand_id;
  String name;
  String description;
  DateTime time;

  Item({
    required this.id,
    required this.category_id,
    required this.brand_id,
    required this.name,
    required this.description,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'category_id': category_id,
      'brand_id': brand_id,
      'name': name,
      'description': description
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      category_id: json['category_id'],
      brand_id: json['brand_id'],
      name: json['name'],
      description: json['description'],
      time:
          json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
    );
  }

  @override
  List<Object> get props {
    return [id, category_id, brand_id, name, description, time];
  }

  @override
  bool get stringify => true;
}
