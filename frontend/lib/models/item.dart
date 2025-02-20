import 'crud.dart';

class Item extends Serialisable {
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
      {required super.id,
      required this.categoryId,
      required this.brandId,
      required this.name,
      required this.alcohol,
      required this.barcode,
      required this.description,
      required this.rating,
      required this.time,
      this.brandName});

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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Item &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.brandId == brandId &&
        other.name == name &&
        other.alcohol == alcohol &&
        other.barcode == barcode &&
        other.description == description &&
        other.rating == rating &&
        other.time == time &&
        other.brandName == brandName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      categoryId,
      brandId,
      name,
      alcohol,
      barcode,
      description,
      rating,
      time,
      brandName,
    );
  }
}
