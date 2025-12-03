import 'dart:convert';

class PokemonModel {
  final String id;
  final String name;
  final String description;
  final String imagePath;

  PokemonModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory PokemonModel.fromMap(Map<String, dynamic> map) {
    return PokemonModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PokemonModel.fromJson(String source) =>
      PokemonModel.fromMap(jsonDecode(source));

  @override
  String toString() =>
      'PokemonModel(id: $id, name: $name, description: $description, imagePath: $imagePath)';
}
