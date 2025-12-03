class DataRelation {
  final String userId;
  final String email;
  final bool isAdmin;
  final List<String> grupID;
  final List<String> pokemonID;

  DataRelation({
    required this.userId,
    required this.email,
    required this.isAdmin,
    required this.grupID,
    required this.pokemonID,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'email': email,
    'isAdmin': isAdmin,
    'grupID': grupID,
    'pokemonID': pokemonID,
  };

  factory DataRelation.fromMap(Map<String, dynamic> map) => DataRelation(
    userId: map['userId'] ?? '',
    email: map['email'] ?? '',
    isAdmin: map['isAdmin'] ?? false,
    grupID: List<String>.from(map['grupID'] ?? []),
    pokemonID: List<String>.from(map['pokemonID'] ?? []),
  );
}