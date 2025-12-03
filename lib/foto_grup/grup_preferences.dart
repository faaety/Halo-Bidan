import 'package:shared_preferences/shared_preferences.dart';
import '../models/gruop_model.dart';

class GroupPreferences {
  static const String _keyGroups = 'groups_list';

  //// INFO: Simpan semua grup ke SharedPreferences
  static Future<void> saveGroups(List<GroupModel> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedGroups =
    groups.map((g) => g.toJson()).toList();
    await prefs.setStringList(_keyGroups, encodedGroups);
  }

  //// INFO: Ambil semua grup dari SharedPreferences
  static Future<List<GroupModel>> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList(_keyGroups);

    if (data == null) return [];
    return data.map((json) => GroupModel.fromJson(json)).toList();
  }

  //// INFO: Update satu grup (misalnya setelah ganti foto)
  static Future<void> updateGroup(GroupModel group) async {
    final groups = await loadGroups();
    final index = groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      groups[index] = group;
      await saveGroups(groups);
    }
  }
}