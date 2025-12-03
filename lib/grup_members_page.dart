  import 'dart:convert';
import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:halobidan/models/model_user.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'db_helper.dart';
  import 'local/data_user.dart';
  import 'models/gruop_model.dart';
  import 'models/pokemon_model.dart';

  class GroupMembersPage extends StatefulWidget {
    final GroupModel group;
    const GroupMembersPage({super.key, required this.group});

    @override
    State<GroupMembersPage> createState() => _GroupMembersPageState();
  }
  class _GroupMembersPageState extends State<GroupMembersPage> {

    final db = DBHelper();
    List<User> _allUsers = [];

    @override
    void initState() {
      super.initState();
      collectData();
      _loadUsers();
    }

    /// INFO: Ambil semua data user yang terdaftar
    Future<void> _loadUsers() async {
      final users = await UserPreferences.getUsers();
      setState(() {
        _allUsers = users;
      });
    }

    ImageProvider _getImageProvider(String path) {
      if (path.isEmpty) return const AssetImage("assets/images/default.png");
      return AssetImage(path);
    }


    ///INFO:Ambil semua nama grup dari database
    Future<List<String>> _getAllGroups() async {
      final dbInstance = await db.database;
      final res = await dbInstance.rawQuery("SELECT DISTINCT groupName FROM members");
      return res.map((e) => e["groupName"].toString()).toList();
    }

    void _showGroupSelection() async {
      final groups = await _getAllGroups(); /// INFO: Ambil semua grup dari database

      if (groups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Belum ada grup tersedia.")),
        );
        return;
      }
    }



    Future<String?> _selectGroup(String currentGroup) async {
      final _currentUser = await UserPreferences.getCurrentUser(); // user login
      final prefs = await SharedPreferences.getInstance();

      /// INFO: Ambil daftar grup
      final groupList = prefs.getStringList('admin@gmail.com_groups') ?? [];
      List<GroupModel> groups = groupList
          .map((g) => GroupModel.fromMap(jsonDecode(g)))
          .toList();

      /// INFO: Hapus grup saat ini
      groups.removeWhere((element) => element.name == widget.group.name.trim());

      /// INFO: FILTER USER
      List<User> dataUser = _allUsers;
      dataUser.removeWhere(
            (element) => element.email == _currentUser!.email,
      );
      if (!_currentUser!.isAdmin) {
        dataUser.removeWhere((element) => element.isAdmin);
      }


      return await showDialog<String>(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxHeight: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pindah ke grup lain",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Daftar User Tujuan:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: _allUsers.isEmpty
                        ? const Center(child: Text("Belum ada user terdaftar."))
                        : ListView.builder(
                      itemCount: _allUsers.length,
                      itemBuilder: (context, index) {
                        final u = _allUsers[index];
                        ImageProvider imageProvider;
                        if (File(u.imagePath!).existsSync()) {
                          /// INFO:kalau path file ada → tampilkan dari galeri/kamera
                          imageProvider = FileImage(File(u.imagePath!));
                        } else {
                          imageProvider = AssetImage(u.imagePath!);
                        }
                        return ListTile(
                          leading: CircleAvatar(backgroundImage: imageProvider),
                          title: Text(u.namaLengkap),
                          subtitle: Text(u.email),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 10, thickness: 2),

                  const Text(
                    "Daftar Grup Tujuan:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: groups.isEmpty
                        ? const Center(child: Text("Belum ada grup terdaftar."))
                        : ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final g = groups[index];
                        ImageProvider imageProvider;
                        if (File(g.imagePath).existsSync()) {
                          imageProvider = FileImage(File(g.imagePath));
                        } else {
                          imageProvider = AssetImage(g.imagePath);
                        }
                        return ListTile(
                          leading: CircleAvatar(backgroundImage: imageProvider),
                          title: Text(g.name),
                          onTap: () => Navigator.pop(context, g.name.trim()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }


    /// INFO:Proses pindah grup
    Future<void> _pindahGrup() async {
      List<PokemonModel> members = dataMember;

      final selectedMembers = await showDialog<List<PokemonModel>>(
        context: context,
        builder: (context) {
          List<bool> selected = List.filled(members.length, false);

          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text("Pilih anggota dari ${widget.group.name}"),
                content: SingleChildScrollView(
                  child: Column(
                    children: List.generate(members.length, (index) {
                      final m = members[index];
                      return CheckboxListTile(
                        value: selected[index],
                        title: Text(m.name),
                        secondary: CircleAvatar(
                          backgroundImage: _getImageProvider(m.imagePath),
                        ),
                        onChanged: (value) {
                          setStateDialog(() {
                            selected[index] = value ?? false;
                          });
                        },
                      );
                    }),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final chosen = <PokemonModel>[];
                      for (int i = 0; i < members.length; i++) {
                        if (selected[i]) chosen.add(members[i]);
                      }
                      Navigator.pop(context, chosen);
                    },
                    child: const Text("Lanjut"),
                  ),
                ],
              );
            },
          );
        },
      );
      if (selectedMembers == null || selectedMembers.isEmpty) return;

      /// INFO: Pilih grup tujuan
      final chosenGroup = await _selectGroup(widget.group.name);
      if (chosenGroup == null) return;

      int movedCount = 0;
      // print("LOG => Original: ${widget.group.name.trim()}");
      // print("LOG => Pindah: ${selectedMembers.map((e) => json.encode(e.name)).join(", ")}");
      // print("LOG => Tujuan: ${json.encode(chosenGroup)}");

      ///INFO: Jalankan update lewat DBHelper
      for (var member in selectedMembers) {
        final res = await db.moveMember(
          widget.group.name.trim(), ///INFO: grup asal
          chosenGroup,       ///INFO: grup tujuan
          member.name,       //INFO: nama anggota

        );
        if (res > 0) movedCount++;
      }

      /// INFO: Refresh UI grup asal
      final updatedMembers = await db.getMembers(widget.group.name);
      setState(() {
        widget.group.members
          ..clear()
          ..addAll(updatedMembers);
      });

      //print("LOG => Pindah: ${selectedMembers.map((e) => json.encode(e.name)).join(", ")}");
      // print("LOG => Tujuan: ${json.encode(chosenGroup)}");

      ///INFO: Tampilkan notifikasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            movedCount > 0
                ? "$movedCount anggota berhasil dipindahkan ke grup $chosenGroup"
                : "Tidak ada anggota yang dipindahkan",
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      /// INFO:Ambil anggota grup tujuan
      final newMembers = await db.getMembers(chosenGroup);

      /// INFO: Reload page tujuan
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupMembersPage(
            group: GroupModel(
              name: chosenGroup,
              members: newMembers,
              description: '',
            ),
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.group.name),
          actions: [
            IconButton(
              onPressed: _pindahGrup,
              icon: const Icon(Icons.move_down),
              tooltip: "Pindah Grup",
            ),
          ],
        ),
        body: dataMember.isEmpty ? const Center(child: Text("Belum ada anggota dalam grup ini.")) : ListView.builder(
          itemCount: dataMember.length,
          itemBuilder: (context, index) {
            final member = dataMember[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: _getImageProvider(member.imagePath),
              ),
              title: Text(member.name),
            );
          },
        ),
      );
    }

    List<PokemonModel> dataMember = [];


    void collectData() async {
      var savedMembers = await db.getMembers(widget.group.name.trim());
      setState(() {
        dataMember = savedMembers;
      });
      // print("LOG => Member in DB: ${json.encode(savedMembers)}");
    }
  }


