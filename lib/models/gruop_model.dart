import 'dart:convert';
import 'pokemon_model.dart';
import 'package:uuid/uuid.dart';

class GroupModel {
  final String id;
  String name;
  final String description;
  final String imagePath;
  final String imageSource;
  List<PokemonModel> members;

  GroupModel({
    String? id,
    required this.name,
    required this.description,
    this.imagePath = '',
    this.imageSource = '',
    this.members = const [],
  }) : id = id ?? const Uuid().v4();
  /// INFO: kalau id kosong, generate otomatis pakai UUID v4.

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    String? imageSource,
    List<PokemonModel>? members,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageSource: imageSource ?? this.imageSource,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'imageSource': imageSource,
      'members': members.map((m) => m.toMap()).toList(),
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      imageSource: map['imageSource'] ?? '',
      members: (map['members'] as List<dynamic>? ?? [])
          .map((m) => PokemonModel.fromMap(m))
          .toList(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory GroupModel.fromJson(String source) =>
      GroupModel.fromMap(jsonDecode(source));

  @override
  String toString() =>
      'GroupModel(id: $id, name: $name, description: $description, imagePath: $imagePath, members: $members)';
}