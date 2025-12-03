import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_helper.dart';
import '../grup_members_page.dart';
import '../local/data_user.dart';
import '../login_screen.dart';
import '../models/gruop_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = DBHelper();
  List<GroupModel> _groups = [];
  String _category = "none"; // kategori user login
  String _currentGroupName = "";

  @override
  void initState() {
    super.initState();
    _loadUserCategory();
    _loadGroupsFromDatabase();
  }

  /// 🔹 Ambil kategori & grup user login dari SharedPreferences
  Future<void> _loadUserCategory() async {
    final user = await UserPreferences.getCurrentUser();
    setState(() {
      _category = user?.category?.trim() ?? "none";
      _currentGroupName = user?.groupName?.trim() ?? "";
    });
  }

  ///INFO: Ambil semua grup dari database (kecuali grup login)
  Future<void> _loadGroupsFromDatabase() async {
    final dbInstance = await db.database;
    final res = await dbInstance.rawQuery("SELECT DISTINCT groupName FROM members");

    final user = await UserPreferences.getCurrentUser();
    final currentGroup = user?.groupName?.trim() ?? "";

    final allGroups = res
        .map((e) => GroupModel(
      name: e['groupName'].toString(),
      description: '',
      members: [],
    ))
        .where((g) => g.name != currentGroup)
        .toList();

    setState(() {
      _groups = allGroups;
    });
  }

  //// INFO:🔹 Dialog: tampilkan semua grup lain untuk pindah
  Future<String?> _showMoveGroupDialog(
      BuildContext context, String currentGroupName) async {
    final dbInstance = await db.database;
    final res =
    await dbInstance.rawQuery("SELECT DISTINCT groupName FROM members");
    List<String> groups =
    res.map((e) => e['groupName'].toString()).toList();
    groups.removeWhere((g) => g == currentGroupName);
    //print("Grup lain (selain '$currentGroupName'): $groups");

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pindah ke grup lain"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: groups.map((g) {
                return ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(g),
                  onTap: () {
                    Navigator.pop(context, g);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// 🗑️ Hapus grup
  Future<void> _deleteItem(int index, String type) async {
    final groupName = _groups[index].name.trim();
    final dbInstance = await db.database;
    await dbInstance
        .delete('members', where: 'groupName = ?', whereArgs: [groupName]);

    setState(() {
      _groups.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Grup '$groupName' telah dihapus")),
    );
  }

  /// 🧾 Daftar grup
  Widget _buildGroupList() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Daftar Grup:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          _groups.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Belum ada grup yang tersedia.",
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _groups.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final g = _groups[index];
              return ListTile(
                onTap: () async {
                  await db.getMembers(g.name.trim());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupMembersPage(group: g),
                    ),
                  );
                },
                leading: g.imagePath != null &&
                    g.imagePath!.isNotEmpty
                    ? CircleAvatar(
                  backgroundImage: g.imageSource == 'asset'
                      ? AssetImage(g.imagePath!)
                      : FileImage(File(g.imagePath!)),
                )
                    : const CircleAvatar(child: Icon(Icons.group)),
                title: Text(g.name),
                subtitle: Text(
                  g.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(index, "groups"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  //// INFO: 🔹 Tombol logout (hanya muncul jika kategori == "none")
  Widget _buildLogoutButton() {
    if (_category != "none") return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextButton(
        onPressed: () async {
          await UserPreferences.logout();
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        child: const Text(
          "Logout",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 🔹 AppBar + Body
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Halo Bidan - ${_currentGroupName.isEmpty ? "Home" : _currentGroupName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Muat Ulang",
            onPressed: _loadGroupsFromDatabase,
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: "Pindah Grup",
            onPressed: () async {
              final selectedGroup =
              await _showMoveGroupDialog(context, _currentGroupName);
              if (selectedGroup != null) {
                print("User memilih pindah ke grup: $selectedGroup");
                // TODO: tambahkan logika update group user di database
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGroupList(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }
}