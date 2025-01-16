import 'package:frontend/models/crud.dart';

class Brand extends Serialisable {
  String name;
  String description;

  Brand({
    required super.id,
    required this.name,
    required this.description,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Brand.fromJson(Map<String, dynamic> data) {
    return Brand(
      id: data['id'],
      name: data['name'],
      description: data['description'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Brand &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description);
  }
}
