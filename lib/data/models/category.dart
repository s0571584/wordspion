import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        isDefault,
      ];

  // Factory-Methode zum Erstellen aus der Datenbank
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      isDefault: (map['is_default'] as int) == 1,
    );
  }

  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_default': isDefault ? 1 : 0,
    };
  }

  // Kopieren mit neuen Werten
  Category copyWith({
    String? id,
    String? name,
    String? description,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, isDefault: $isDefault)';
  }
}
