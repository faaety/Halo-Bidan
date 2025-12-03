import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:halobidan/components/elements.dart';
import 'package:halobidan/detail_page_pokemon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'db_helper.dart';
import 'foto_grup/grup_preferences.dart';
import 'models/gruop_model.dart';
import 'grup_members_page.dart';
import 'local/data_user.dart';
import 'tambah_baru_pokemon.dart';
import 'halaman_search_pokemon.dart';
import 'login_screen.dart';
import 'package:halobidan/models/pokemon_model.dart';
import 'package:halobidan/models/model_user.dart';
import 'package:path/path.dart' as p;



class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  Future<void> pindahkanGroupKeUserLain(GroupModel group, String emailUserTujuan) async {
    final prefs = await SharedPreferences.getInstance();

    /// INFO:Ambil grup milik user asal
    final String emailUserAsal = _currentUser!.email;
    final List<String> asalGroupsData =
        prefs.getStringList('${emailUserAsal}_groups') ?? [];

    List<GroupModel> asalGroups = asalGroupsData
        .map((g) => GroupModel.fromMap(jsonDecode(g)))
        .toList();

    /// INFO:Hapus grup dari user asal
    asalGroups.removeWhere((g) => g.name == group.name);

    await prefs.setStringList(
      '${emailUserAsal}_groups',
      asalGroups.map((g) => jsonEncode(g.toMap())).toList(),
    );

    /// INFO: Ambil grup milik user tujuan
    final List<String> tujuanGroupsData =
        prefs.getStringList('${emailUserTujuan}_groups') ?? [];

    List<GroupModel> tujuanGroups = tujuanGroupsData
        .map((g) => GroupModel.fromMap(jsonDecode(g)))
        .toList();

    //INFO: Pastikan belum ada grup dengan nama sama
    final bool exists = tujuanGroups.any((g) => g.name == group.name);
    if (!exists) {
      tujuanGroups.add(group);

      await prefs.setStringList(
        '${emailUserTujuan}_groups',
        tujuanGroups.map((g) => jsonEncode(g.toMap())).toList(),
      );
    }

    ///INFO: Update UI (hapus grup dari user asal)
    setState(() {
      _groups = asalGroups;
    });

   //print(" LOG => Grup '${group.name}' berhasil dipindahkan ke $emailUserTujuan");
  }

  /// INFO: BUAT IMAGE KE STORANGE
  Future<String?> _pickGroupImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return null; /// INFO: user batal pilih gambar

    /// INFO: Dapatkan folder penyimpanan app
    final appDir = await getApplicationDocumentsDirectory();

    /// INFO: Nama file yang aman
    final fileName = p.basename(pickedFile.path); 

    /// INFO: Lokasi tujuan penyimpanan
    final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
    //print("LOG => ========== Image Saved To: ${savedImage.path} ==========");

    /// INFO: Kembalikan path lokal dari gambar yang disimpan
    return savedImage.path;
  }


  Future<void> _saveDefaultDataIfEmpty() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    final email = _currentUser!.email;

    ///  INFO: Cek apakah sudah ada data
    final hasAnimals = prefs.containsKey('${email}_animals');
    final hasToys = prefs.containsKey('${email}_toys');

    if (!hasAnimals || !hasToys) {
      /// INFO: Tambahkan Data Delfaut Harcode
      _animals = [
        PokemonModel(
          id: "1",
          name: "Kelinci",
          description: "Hewan mamalia kecil yang lucu, suka melompat dan memiliki telinga panjang.",
          imagePath: "assets/images/binatang1.jpg",
        ),
        PokemonModel(
          id: "2",
          name: "Siput",
          description: "Hewan bercangkang yang bergerak lambat dan hidup di tempat lembap.",
          imagePath: "assets/images/binatang2.jpg",
        ),
        PokemonModel(
          id: "3",
          name: "Landak",
          description: "Hewan kecil dengan duri tajam di punggungnya yang digunakan untuk melindungi diri.",
          imagePath: "assets/images/binatang3.jpg",
        ),
      ];

      _toys = [
        PokemonModel(
          id: "4",
          name: "Cardboard box full of toys",
          description: "Kotak kardus berisi berbagai mainan seru yang bisa dimainkan bersama teman.",
          imagePath: "assets/images/Mainan1.jpg",
        ),
        PokemonModel(
          id: "5",
          name: "Boneka Beruang",
          description: "Mainan berbentuk beruang yang lembut dan cocok untuk dipeluk saat tidur.",
          imagePath: "assets/images/Mainan2.jpg",
        ),
        PokemonModel(
          id: "6",
          name: "Kuda-Kudaan",
          description: "Mainan klasik berbentuk kuda yang bisa dinaiki anak-anak untuk bermain imajinatif.",
          imagePath: "assets/images/Mainan3.jpg",
        ),
      ];


      /// INFO: Simpan ke SharedPreferences
      await prefs.setStringList(
          '${email}_animals',
          _animals.map((a) => jsonEncode(a.toMap())).toList());
      await prefs.setStringList(
          '${email}_toys',
          _toys.map((t) => jsonEncode(t.toMap())).toList());
    }
  }

  final db = DBHelper();

  User? _currentUser;
  List<PokemonModel> _animals = [];
  List<PokemonModel> _toys = [];
  List<GroupModel> _groups = [];
  List<String> imageOptions = [];
  List<User> _allUsers = [];
  String _category = "none";


  @override
  void initState() {
    super.initState();

    /// INFO:Load user & data user
    loadCurrentLoggedUser();
    loadAllUsers();

    /// INFO: Menyiapkan gambar asset untuk profil grup
    imageOptions =
        List.generate(10, (index) => "assets/images/gambar${index + 1}.jpg");

    /// INFO: Setelah build pertama selesai, isi data default kalau kosong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveDefaultDataIfEmpty();
    });
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith("assets/")) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  /// INFO: Ambil semua data user yang terdaftar
  Future<void> loadAllUsers() async {
    final users = await UserPreferences.getUsers();
    setState(() {
      _allUsers = users;
    });
  }

  ///INFO:Ambil semua nama grup dari database
  Future<List<String>> _getAllGroups() async {
    final dbInstance = await db.database;
    final res = await dbInstance.rawQuery(
        "SELECT DISTINCT groupName FROM members");
    return res.map((e) => e["groupName"].toString()).toList();
  }

  /// INFO: Ambil data user yang login saat ini
  Future<void> loadCurrentLoggedUser() async {
    final user = await UserPreferences.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
    if (user != null) {
      loadUserData(user.email);
    }
  }

  /// INFO: Load data animals, toys, groups yang terikat dengan email user
  Future<void> loadUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();

    final currentUser = _currentUser;

    if (currentUser != null && currentUser.isAdmin) {
      /// INFO: Admin ambil semua grup
      final List<String> storedGroups = prefs.getStringList(
          'admin@gmail.com_groups') ?? [];
      final List<GroupModel> decodedGroups = storedGroups
          .map((g) => GroupModel.fromMap(jsonDecode(g)))
          .toList();
      _groups = List.from(decodedGroups);

      /// INFO: Admin: ambil semua animals & toys dari semua user
      _animals = [];
      _toys = [];
      final allUsers = await UserPreferences.getUsers();
      for (var u in allUsers) {
        final userAnimals = prefs.getStringList('${u.email}_animals') ?? [];
        final userToys = prefs.getStringList('${u.email}_toys') ?? [];
        _animals.addAll(
            userAnimals.map((a) => PokemonModel.fromMap(jsonDecode(a))));
        _toys.addAll(userToys.map((t) => PokemonModel.fromMap(jsonDecode(t))));
      }
    } else {
      /// INFO:User biasa
      final animalList = prefs.getStringList('${email}_animals') ?? [];
      final toyList = prefs.getStringList('${email}_toys') ?? [];
      final groupList = prefs.getStringList('${email}_groups') ?? [];

      _animals =
          animalList.map((a) => PokemonModel.fromMap(jsonDecode(a))).toList();
      _toys = toyList.map((t) => PokemonModel.fromMap(jsonDecode(t))).toList();
      _groups =
          groupList.map((g) => GroupModel.fromMap(jsonDecode(g))).toList();
    }
    setState(() {});
  }


  Future<void> _saveData() async {
    if (_currentUser == null) return;
    final email = _currentUser!.email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        '${email}_animals',
        _animals.map((a) => jsonEncode(a.toMap())).toList());
    await prefs.setStringList(
        '${email}_toys', _toys.map((t) => jsonEncode(t.toMap())).toList());
    await prefs.setStringList(
        '${email}_groups', _groups.map((g) => jsonEncode(g.toMap())).toList());
  }

  Widget _buildListWithContainer(List<PokemonModel> items, String category) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];

          ImageProvider imageProvider;
          if (File(item.imagePath).existsSync()) {
            /// INFO:kalau path file ada → tampilkan dari galeri/kamera
            imageProvider = FileImage(File(item.imagePath));
          } else {
            imageProvider = AssetImage(item.imagePath);
          }
          return ListTile(
            leading: CircleAvatar(backgroundImage: imageProvider),
            title: Text(item.name),
            subtitle: Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailPage(item: item)),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(index, category),
            ),
          );
        },
      ),
    );
  }

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
                style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _groups.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final g = _groups[index];
               // print("LOG => Data: ${g.name} | Image Source: ${g.imageSource} | Path: ${g.imagePath}");
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
                  leading: g.imagePath.isNotEmpty ? CircleAvatar(
                    backgroundImage: g.imageSource == 'asset' ? AssetImage(g.imagePath) : FileImage(File(g.imagePath)),
                  ) : GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);

                      if (image == null) return;

                      final appDir = await getApplicationDocumentsDirectory();
                      final fileName = p.basename(image.path);
                      final savedPath = p.join(appDir.path, fileName);

                      await File(image.path).copy(savedPath);
                      final updatedGroup = g.copyWith(
                        imagePath: savedPath,
                        imageSource: 'file',
                      );
                      setState(() {
                        _groups[index] = updatedGroup;
                      });

                      await GroupPreferences.updateGroup(updatedGroup);

                    },
                    child: const CircleAvatar(child: Icon(Icons.group)),
                  ),
                  title: Text(g.name),
                  subtitle: Text(g.description,
                      maxLines: 1, overflow: TextOverflow.ellipsis
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(
                            Icons.switch_right, color: Colors.white),
                        label: const Text(
                            "Pindah", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          List<User> dataUser = _allUsers;
                          dataUser.removeWhere((element) =>
                          element.email == _currentUser!.email,);
                          if (!_currentUser!.isAdmin) {
                            dataUser.removeWhere((element) => element.isAdmin);
                          }
                          /// INFO: Variabel sementara untuk menampung user yang dipilih
                          String? selectedEmail;

                          /// INFO: Pastikan list user tidak kosong
                          if (dataUser.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  "Tidak ada user lain untuk dipilih")
                              ),
                            );
                            return;
                          }

                          /// INFO: Tampilkan AlertDialog
                          showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setStateDialog) {
                                  return AlertDialog(
                                    title: Text("Pindahkan Grup '${g.name}' ke User Lain"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            labelText: "Pilih User Tujuan",
                                            border: OutlineInputBorder(),
                                          ),
                                          value: selectedEmail,
                                          items: dataUser.map((user) {
                                            return DropdownMenuItem<String>(
                                              value: user.email,
                                              child: Text(user.namaLengkap),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setStateDialog(() {
                                              selectedEmail = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text("Batal"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () async {
                                          if (selectedEmail == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Silakan pilih user tujuan dulu")),
                                            );
                                            return;
                                          }

                                          final selectedUser = dataUser.firstWhere(
                                                (u) => u.email == selectedEmail,
                                          );

                                             if (selectedUser.email == _currentUser!.email) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Tidak bisa memindahkan ke diri sendiri!")),
                                            );
                                            return;
                                          }

                                          /// INFO: Panggil fungsi pindahkan grup
                                          await pindahkanGroupKeUserLain(g, selectedUser.email);

                                          /// INFO: Tutup dialog
                                          Navigator.pop(context);

                                          /// INFO: Tampilkan notifikasi sukses
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Grup '${g.name}' berhasil dipindahkan ke ${selectedUser.namaLengkap}!")),
                                          );
                                        },
                                        child: const Text("Pindahkan"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: "Hapus Grup",
                        onPressed: () => _deleteItem(index, "groups"),
                      ),
                    ],
                  ),
                );
              }
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];

    if (_category == "animals") {
      content.add(_buildListWithContainer(_animals, "animals"));
    } else if (_category == "toys") {
      content.add(_buildListWithContainer(_toys, "toys"));
    } else if (_category == "groups") {
      content.add(_buildGroupList());
    } else {

      ///INFO: menu utama halo
      content.add(
        ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: () {
              if (_currentUser == null) {
                return const AssetImage(
                    "assets/images/labubu.png") as ImageProvider;
              }
              if (_currentUser!.isAdmin) {
                return const AssetImage(
                    "assets/images/labubu.png") as ImageProvider;
              }
              if (_currentUser!.imagePath != null &&
                  _currentUser!.imagePath!.isNotEmpty) {
                return FileImage(
                    File(_currentUser!.imagePath!)) as ImageProvider;
              }
              return const AssetImage(
                  "assets/images/default_user.jpg") as ImageProvider;
            }(),
          ),

          title: Text("Halo, ${_currentUser?.namaLengkap ?? "User"} 👋"),
          subtitle: Text(_currentUser?.email ?? ""),
        ),
      );

      /// INFO: Kotak List
      content.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentUser?.isAdmin == true
                    ? "Lihat List"
                    : "Lihat Kendaraan",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),

              if (_currentUser?.isAdmin == true) ...[
                ListTile(
                  title: const Text("Binatang"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => setState(() => _category = "animals"),
                ),
              ] else
                ...[
                  ListTile(
                    title: const Text("Mobil"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => setState(() => _category = "animals"),
                  ),
                ],
            ],
          ),
        ),
      );

      /// INFO:Kotak List
      content.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentUser?.isAdmin == true
                    ? "Lihat List"
                    : "Lihat Kendaraan",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),

              if (_currentUser?.isAdmin == true) ...[
                ListTile(
                  title: const Text("Mainan"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => setState(() => _category = "toys"),
                ),
              ] else
                ...[
                  ListTile(
                    title: const Text("Motor"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => setState(() => _category = "toys"),
                  ),
                ],
            ],
          ),
        ),
      );

      /// INFO:Kotak Grup
      content.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Lihat Grup",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              ListTile(
                title: const Text("Grup"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => setState(() => _category = "groups"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: _category != "none",
        leading: _category != "none"
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _category = "none";
            });
          },
        )
            : null,
        title: Text(
          _category == "animals"
              ? _currentUser!.isAdmin ? "Binatang" : "Mobil"
              : _category == "toys"
              ? _currentUser!.isAdmin ? "Mainan" : "Motor"
              : _category == "groups"
              ? "Grup"
              : "Halo Bidan",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              if (_category == "animals") {
                showSearch(
                  context: context,
                  delegate: ItemSearchDelegate(_animals),
                );
              } else if (_category == "toys") {
                showSearch(
                  context: context,
                  delegate: ItemSearchDelegate(_toys),
                );
              } else {
                final allData = [..._animals, ..._toys,];
                showSearch(
                  context: context,
                  delegate: ItemSearchDelegate(allData),
                );
              }
            },
          ),

          if (_category == "none")
            TextButton(
              onPressed: () async {
                await UserPreferences.logout();

                /// INFO: clear pengguna user
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
              child: const Text("Logout",
                  style: TextStyle(color: Colors.black)
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(child: Column(children: content)),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /// INFO: Hanya admin yang bisa hapus db
          if (_currentUser?.isAdmin == true) ...[
            FloatingActionButton(
              heroTag: "reset",
              onPressed: () async {
                final confirm = await Elements.confirmationDialog(
                  context,
                  title: "Reset Database",
                  message: "Apakah Anda yakin ingin menghapus semua data dalam database?",
                );
                if (confirm == DialogAction.yes) {
                  await db.resetDataMember();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Semua data member berhasil dihapus!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Icon(Icons.delete),
            ),
            const SizedBox(height: 20),
          ],

          /// INFO: Tombol tambah tetap muncul untuk semua user
          FloatingActionButton(
            heroTag: "add",
            onPressed: () async {
              if (_category == "animals" || _category == "toys") {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateData(
                      category: _category,
                      currentUser: _currentUser,
                    ),
                  ),
                );

                if (result != null) {
                  setState(() {
                    if (_category == "animals") {
                      _animals.add(PokemonModel.fromMap(result));
                    } else if (_category == "toys") {
                      _toys.add(PokemonModel.fromMap(result));
                    }
                  });
                  _saveData();
                }
              } else if (_category == "groups") {
                await _createNewGroup();
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  ///INFO: DELETE DB
  void _deleteItem(int i, String category) {
    setState(() {
      if (category == "animals") {
        _animals.removeAt(i);
      } else if (category == "toys") {
        _toys.removeAt(i);
      } else if (category == "groups") {
        _groups.removeAt(i);
      }
    });
    _saveData();
  }

  Future<void> _createNewGroup() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String? selectedImage;
    final result = await showDialog<GroupModel>(
      context: context,
      builder: (context) {
        File? pickedImage;

        ///INFO: untuk kamera/galeri
        String? selectedAsset;

        /// INFO:untuk asset
        final picker = ImagePicker();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Buat Grup Baru"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Nama Grup"),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: "Deskripsi"),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    /// INFO:Preview gambar pilihan
                    if (pickedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          pickedImage!,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      if (selectedAsset != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            selectedAsset!,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Belum ada gambar"),
                        ),

                    const SizedBox(height: 16),

                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              final imagePath = await _pickGroupImage(ImageSource.camera); /// INFO: ambil dan simpan gambar dari kamera
                              if (imagePath != null) {
                                setStateDialog(() {
                                  pickedImage = File(imagePath);
                                  selectedAsset = null;
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text("Ambil dari Kamera", style: TextStyle(color: Colors.white)),
                          ),
                        ), // INFO: Tombol Ambil Gambar Dari Kamera
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              final imagePath = await _pickGroupImage(ImageSource.gallery); /// INFO: ambil dan simpan gambar dari galeri
                              if (imagePath != null) {
                                setStateDialog(() {
                                  pickedImage = File(imagePath);
                                  selectedAsset = null;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            label: const Text("Ambil dari Galeri", style: TextStyle(color: Colors.white)),
                          ),
                        ), // INFO: Tombol Ambil Gambar Dari Galeri
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Pilih Gambar:",
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),

                    /// INFO:🔹 Pilih dari asset list
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: imageOptions.map((imgPath) {
                        final isSelected = selectedAsset == imgPath;
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              selectedAsset = imgPath;
                              pickedImage = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors
                                    .transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              imgPath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Error"),
                          content: const Text("Nama grup dan deskripsi tidak boleh kosong."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    String? imagePath;
                    String? imageSource;
                    if (pickedImage != null) {
                      imagePath = pickedImage!.path;
                      imageSource = "file";
                    } else if (selectedAsset != null) {
                      imagePath = selectedAsset!;
                      imageSource = "asset";
                    }

                    final newGroup = GroupModel(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      description: descController.text,
                      imagePath: imagePath.toString(),
                      imageSource: imageSource.toString(),
                      members: [],
                    );

                    Navigator.pop(context, newGroup);
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );

    ///INFO: buat fungsi grupnya
    if (result != null) {
      setState(() => _groups.add(result));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        '${_currentUser!.email}_groups',
        _groups.map((g) => jsonEncode(g.toMap())).toList(),
      );

      final List<String> storedGroups = prefs.getStringList(
          '${_currentUser!.email}_groups') ?? [];
      final List<GroupModel> decodedGroups = storedGroups
          .map((g) => GroupModel.fromMap(jsonDecode(g)))
          .toList();
      final List<GroupModel> newGroup = List.from(decodedGroups);

      /// INFO: Remove data current user
      //print("LOG => Grup Sekarang: [${newGroup.map((e) => e.name).join(", ")}]");
      if (_currentUser != null && !_currentUser!.isAdmin) {
        final List<String> storedGroups = prefs.getStringList(
            'admin@gmail.com_groups') ?? [];

        /// INFO: Decode ke list of map
        final List<GroupModel> decodedGroups = storedGroups
            .map((g) => GroupModel.fromMap(jsonDecode(g)))
            .toList();

        //print("LOG => Grup: ${decodedGroups.map((e) => e.name).join(", ")}");

        /// INFO: Cek apakah sudah ada group dengan nama yang sama
        final bool exists =
        decodedGroups.any((g) => g.name.toString() == result.name);

        if (!exists) {
          /// INFO: Tambahkan group baru
          storedGroups.add(jsonEncode(result.toMap()));

          /// INFO: Simpan kembali
          await prefs.setStringList('admin@gmail.com_groups', storedGroups);
        }
      }
    }
  }

}
