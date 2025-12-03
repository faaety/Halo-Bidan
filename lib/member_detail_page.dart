import 'dart:io';
import 'package:flutter/material.dart';
import 'models/pokemon_model.dart';
import 'models/gruop_model.dart';
import 'chatroom_page.dart';

class MemberDetailPage extends StatelessWidget {
  final PokemonModel member;
  final GroupModel group;

  const MemberDetailPage({
    super.key,
    required this.member,
    required this.group,
  });

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith("assets/")) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context), /// INFO: klik balik tutup
          child: InteractiveViewer(
            child: Center(
              child: Image(image: _getImageProvider(member.imagePath)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(member.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// INFO: 🔹 Foto Profil bisa di-zoom (langsung di dialog)
            GestureDetector(
              onTap: () => _showFullScreenImage(context),
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _getImageProvider(member.imagePath),
              ),
            ),

            const SizedBox(height: 20),

            /// INFO:🔹 Nama & Deskripsi
            Text(
              member.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              member.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// INFO: 🔹 Tombol Masuk Chatroom


            const Divider(height: 40),

            /// INFO: 🔹 Daftar Anggota Grup
            const Text(
              "Anggota Grup:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.members.length,
              itemBuilder: (context, index) {
                final m = group.members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: _getImageProvider(m.imagePath),
                  ),
                  title: Text(m.name),
                  subtitle: Text(m.description),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
