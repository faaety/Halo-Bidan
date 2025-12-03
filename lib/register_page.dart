import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'login_screen.dart';
import 'local/data_user.dart';
import 'models/model_user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool isLoaded = false; User? data;
  @override
  void didChangeDependencies() {
    if (!isLoaded) {
      final setting = ModalRoute.of(context)?.settings;
      if (setting != null) {
        setState(() {
          data = setting.arguments as User?;
          if (data != null) {
            _namaLengkapController.text = data!.namaLengkap;
            _emailController.text = data!.email;
            _passwordController.text = data!.password;
            gender = data!.gender;
            _phoneController.text = data!.phone;
            _alamatController.text = data!.alamat;
          }
          isLoaded = true;
        });
        // print("LOG => Ada!");
      }
    }
    super.didChangeDependencies();
  }

  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  String? gender;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// INFO: simpan foto ke folder permanen
  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    final image = File(imagePath);
    final newImage = await image.copy('${directory.path}/$name.jpg');
    return newImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final permanentImage = await saveImagePermanently(
          pickedFile.path); /// INFO: copy ke documents
      setState(() {
        _imageFile = permanentImage;
      });
    }
  }

  Future<void> _registerUser() async {
    final nama = _namaLengkapController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();
    final alamat = _alamatController.text.trim();

    if (_imageFile == null) {
      _showErrorDialog("Foto profil harus dipilih (kamera/galeri).");
      return;
    }
    if (nama.isEmpty) {
      _showErrorDialog("Nama lengkap harus diisi!");
      return;
    }
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorDialog("Format email tidak valid! Contoh: fatimah@gmail.com");
      return;
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=(?:.*\d){3,})(?=.*[!@#\$&*~]).{6,}$').hasMatch(
        password)) {
      _showErrorDialog(
          "Password minimal 6 karakter, harus ada 1 huruf besar, minimal 3 angka, dan 1 simbol. Contoh: FaTima123@");
      return;
    }
    if (password != confirmPassword) {
      _showErrorDialog("Password dan konfirmasi tidak sama!");
      return;
    }
    if (gender == null) {
      _showErrorDialog("Jenis kelamin harus dipilih!");
      return;
    }
    if (phone.isEmpty) {
      _showErrorDialog("Nomor HP tidak boleh kosong!");
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showErrorDialog("Nomor HP harus angka semua!");
      return;
    }
    if (!phone.startsWith("0")) {
      _showErrorDialog("Nomor HP harus diawali dengan angka 0!");
      return;
    }
    if (alamat
        .split(" ")
        .length < 5) {
      _showErrorDialog(
          "Alamat minimal 5 kata. Contoh: Jl. Tebet II No 12 RT 08 RW 02");
      return;
    }
    if (!alamat.toLowerCase().contains("jl") &&
        !alamat.toLowerCase().contains("jalan")) {
      _showErrorDialog(
          "Alamat harus mencantumkan nama jalan. Contoh: Jl. Tebet II");
      return;
    }
    if (!RegExp(r'\d+').hasMatch(alamat) &&
        !alamat.toLowerCase().contains("no")) {
      _showErrorDialog("Alamat harus mencantumkan nomor rumah. Contoh: No. 12");
      return;
    }
    if (!alamat.toLowerCase().contains("rt")) {
      _showErrorDialog("Alamat harus mencantumkan RT. Contoh: RT 08");
      return;
    }
    if (!alamat.toLowerCase().contains("rw")) {
      _showErrorDialog("Alamat harus mencantumkan RW. Contoh: RW 02");
      return;
    }

    final allUsers = await UserPreferences.getUsers();
    if (allUsers.any((u) => u.email == email)) {
      _showErrorDialog("Email sudah terdaftar, gunakan email lain!");
      return;
    }

    final newUser = User(
      id: const Uuid().v4(),
      namaLengkap: nama,
      email: email,
      password: password,
      phone: phone,
      alamat: alamat,
      gender: gender ?? "",
      imagePath: _imageFile?.path,
      isAdmin: false,
    );


    if (!await UserPreferences.saveUser(newUser)) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi berhasil, silakan login!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _editUser(User oldUser) async {
    final nama = _namaLengkapController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final alamat = _alamatController.text.trim();

    /// INFO: Validasi sama seperti register (tapi tanpa confirm password)
    if (nama.isEmpty) {
      _showErrorDialog("Nama lengkap harus diisi!");
      return;
    }
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorDialog("Format email tidak valid! Contoh: fatimah@gmail.com");
      return;
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=(?:.*\d){3,})(?=.*[!@#\$&*~]).{6,}$')
        .hasMatch(password)) {
      _showErrorDialog(
          "Password minimal 6 karakter, harus ada 1 huruf besar, minimal 3 angka, dan 1 simbol. Contoh: FaTima123@");
      return;
    }
    if (gender == null) {
      _showErrorDialog("Jenis kelamin harus dipilih!");
      return;
    }
    if (phone.isEmpty) {
      _showErrorDialog("Nomor HP tidak boleh kosong!");
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showErrorDialog("Nomor HP harus angka semua!");
      return;
    }
    if (!phone.startsWith("0")) {
      _showErrorDialog("Nomor HP harus diawali dengan angka 0!");
      return;
    }
    if (alamat.split(" ").length < 5) {
      _showErrorDialog(
          "Alamat minimal 5 kata. Contoh: Jl. Tebet II No 12 RT 08 RW 02");
      return;
    }
    if (!alamat.toLowerCase().contains("jl") &&
        !alamat.toLowerCase().contains("jalan")) {
      _showErrorDialog(
          "Alamat harus mencantumkan nama jalan. Contoh: Jl. Tebet II");
      return;
    }
    if (!RegExp(r'\d+').hasMatch(alamat) &&
        !alamat.toLowerCase().contains("no")) {
      _showErrorDialog("Alamat harus mencantumkan nomor rumah. Contoh: No. 12");
      return;
    }
    if (!alamat.toLowerCase().contains("rt")) {
      _showErrorDialog("Alamat harus mencantumkan RT. Contoh: RT 08");
      return;
    }
    if (!alamat.toLowerCase().contains("rw")) {
      _showErrorDialog("Alamat harus mencantumkan RW. Contoh: RW 02");
      return;
    }

    /// INFO: Kalau user tidak pilih foto baru, pakai foto lama
    final imagePath = _imageFile != null ? _imageFile!.path : oldUser.imagePath;

    final updatedUser = User(
      id: oldUser.id,
      namaLengkap: nama,
      email: email,
      password: password,
      phone: phone,
      alamat: alamat,
      imagePath: imagePath,
      gender: gender ?? "",
      isAdmin: oldUser.isAdmin,
    );


    /// INFO: Ambil semua user, replace yg email sama
    final allUsers = await UserPreferences.getUsers();
    final index = allUsers.indexWhere((u) => u.email == oldUser.email);
    if (index != -1) {
      allUsers[index] = updatedUser;
      await UserPreferences.saveUsers(allUsers);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!')),
    );

    Navigator.pop(context); // kembali ke halaman sebelumnya
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
        AlertDialog(
          title: const Text("Mohon isi dengan benar"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) =>
            Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Kamera"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Galeri"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
        );
      },
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
        child: _imageFile == null
            ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data == null ? "Register" : "Edit Profile"),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.deepPurple, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data == null ? "Create Account" : "Manage Your Profile Data",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),

                _buildProfileImage(),
                const SizedBox(height: 20),

                /// INFO:input fields tetap sama
                TextField(
                  controller: _namaLengkapController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge),
                    labelText: "Nama Lengkap",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons
                            .visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                if (data == null) TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    labelText: "Confirm Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons
                            .visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                if (data == null) const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(
                        value: "Laki-laki", child: Text("Laki-laki")),
                    DropdownMenuItem(
                        value: "Perempuan", child: Text("Perempuan")),
                  ],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.wc),
                    labelText: "Jenis Kelamin",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: "Nomor HP",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _alamatController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.home),
                    labelText: "Alamat Rumah",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => data == null ? _registerUser() : _editUser(data!),
                  child: Text(
                    data == null ? "Register" : "Save Changes",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}