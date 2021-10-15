import 'package:frontend/models/crud.dart';
import 'package:equatable/equatable.dart';

class Category extends Serialisable with EquatableMixin {
  int id;
  String name;
  String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Category.fromJson(Map<String, dynamic> data) {
    return Category(
      id: data['id'],
      name: data['name'],
      description: data['description'],
    );
  }

  @override
  List<Object> get props {
    return [id, name, description];
  }

  @override
  bool get stringify => true;
}