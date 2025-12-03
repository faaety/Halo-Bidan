import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon_model.dart';

class PrefsHelper {
  static const String key = "pokemon_items";

  static Future<void> saveItem(PokemonModel model) async {
    final prefs = await SharedPreferences.getInstance();

    String? saved = prefs.getString(key);
    List<dynamic> jsonList = saved != null ? jsonDecode(saved) : [];

    jsonList.add(model.toJson());

    await prefs.setString(key, jsonEncode(jsonList));
  }

  static Future<List<PokemonModel>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString(key);

    if (saved != null) {
      List<dynamic> jsonList = jsonDecode(saved);
      return jsonList.map((e) => PokemonModel.fromJson(e)).toList();
    }
    return [];
  }
}
