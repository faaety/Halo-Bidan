import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models/model_user.dart';

class CreateData extends StatefulWidget {
  final String category;
  final User? currentUser;
  const CreateData({super.key, required this.category, required this.currentUser});

  @override
  _CreateDataState createState() => _CreateDataState();
}

class _CreateDataState extends State<CreateData> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> imageOptions = []; /// INFO:list gambar (asset + custom)
  String? imagePath;
  int imageIndex = -1;

  @override
  void initState() {
    super.initState();
    /// INFO:daftar avatar default
    imageOptions = [
      "assets/images/gambar1.jpg",
      "assets/images/gambar2.jpg",
      "assets/images/gambar3.jpg",
      "assets/images/gambar4.jpg",
      "assets/images/gambar5.jpg",
      "assets/images/gambar6.jpg",
      "assets/images/gambar7.jpg",
      "assets/images/gambar8.jpg",
      "assets/images/gambar9.jpg",
      "assets/images/gambar10.jpg",
    ];
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        /// INFO:masukkan gambar custom ke awal list
        imageOptions.insert(0, picked.path);
        imagePath = picked.path;
        imageIndex = 0;
      });
    }
  }

  void _saveItem() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty || imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, deskripsi, dan gambar harus diisi.")),
      );
      return;
    }

    Navigator.pop(context, {
      'name': name,
      'description': description,
      'imagePath': imagePath!,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambahkan ${widget.category == 'animals' ? widget.currentUser!.isAdmin ? 'Binatang' : "Mobil" :  widget.currentUser!.isAdmin ? "Mainan" : 'Motor'} Baru',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// INFO: pilihan gambar
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageOptions.length + 1, /// INFO: +1 buat tombol tambah
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 2),
                          color: Colors.grey.shade200,
                        ),
                        child: const Icon(Icons.add_a_photo, size: 40),
                      ),
                    );
                  }

                  final realIndex = index - 1;
                  final path = imageOptions[realIndex];
                  final isFile = File(path).existsSync();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        imagePath = path;
                        imageIndex = realIndex;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: imageIndex == realIndex ? Colors.deepPurple : Colors.grey,
                          width: imageIndex == realIndex ? 4 : 2,
                        ),
                        image: DecorationImage(
                          image: isFile
                              ? FileImage(File(path))
                              : AssetImage(path) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),


            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),


            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 40),


            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
