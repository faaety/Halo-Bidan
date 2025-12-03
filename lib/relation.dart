import 'package:collection/collection.dart';
import 'package:halobidan/relation_dart.dart';
import 'group_service.dart';
import 'models/gruop_model.dart';

List<DataRelation> databaseLocal = [
  DataRelation(
    userId: "user123",
    email: "someone@gmail.com",
    isAdmin: false,
    grupID: ["grp123", "grp456"],
    pokemonID: ["poke123", "poke456"],
  ),
  DataRelation(
    userId: "userFatimah",
    email: "fatimah@gmail.com",
    isAdmin: true,
    grupID: [],
    pokemonID: [],
  ),
];

List<GroupModel> getAllGroupsForAdmin() {
  return List.from(allGroupsDatabase);
}

List<GroupModel> getGroupsForUser(String userId) {
  final relation = databaseLocal.firstWhereOrNull((r) => r.userId == userId);
  if (relation == null) return [];
  return allGroupsDatabase
      .where((g) => relation.grupID.contains(g.id))
      .toList();
}
