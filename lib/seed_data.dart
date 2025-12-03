import 'package:halobidan/data_static/pokemons.dart';
import 'db_helper.dart';
import 'models/pokemon_model.dart';

Future<void> setData() async {
  final db = DBHelper();

  Map<String, List<PokemonModel>> dataStatic = Pokemons.all;

  for (var entry in dataStatic.entries) {
    String key = entry.key;
    List<PokemonModel> list = entry.value;

    //print("LOG => Uploading Group: $key");
    for (var item in list) {
      await db.insertMember(item, key);
    }
  }
}
