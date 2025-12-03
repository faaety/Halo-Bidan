import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/model_user.dart';

class UserPreferences {
  static const String _usersKey = "users"; /// INFO: waktu register
  static const String _currentUserKey = "currentUser"; /// INFO: waktu login, waktu logout

  /// INFO: user dari SharedPreferences
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getStringList(_usersKey) ?? [];


    print("LOG => ${json.encode(usersString)}");
    return usersString.map((e) => User.fromMap(jsonDecode(e))).toList();
  }

  Future<void> createDefaultAdmin() async {
    final users = await UserPreferences.getUsers();

    if (!users.any((u) => u.isAdmin)) {
      final adminUser = User(
        id: const Uuid().v4(),
        namaLengkap: "Admin",
        email: "admin@gmail.com",
        password: "Admin123@",
        phone: "",
        alamat: "",
        gender: "",
        imagePath: "assets/images/labubu.png",
        isAdmin: true,
      );

      await UserPreferences.saveUser(adminUser);
    }
  }

  /// INFO:user sharedPreferen
  static Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = users.map((u) => jsonEncode(u.toMap())).toList();
    await prefs.setStringList(_usersKey, usersString);
  }

  /// INFO: tambah user baru
  static Future<bool> saveUser(User user) async {
    final users = await getUsers();

    /// INFO: cek kalau email sudah terpakai
    final exists = users.any((u) => u.email == user.email);
    if (exists) return false;

    users.add(user);
    await saveUsers(users);
    return true;
  }

  /// INFO: Login: cek email & password
  static Future<User?> authenticateUser(String email, String password) async {
    final users = await getUsers();
    try {
      final user = users.firstWhere(
            (u) => u.email == email && u.password == password,
      );

      /// INFO: Simpan sebagai user aktif
      await setCurrentUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  /// INFO: Ambil user yang sedang login
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_currentUserKey);
    if (userString == null) return null;
    return User.fromMap(jsonDecode(userString));
  }

  /// INFO: set user yang sedang login
  static Future<void> setCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));

    /// INFO: Pastikan juga user ini tersimpan di daftar "users"
    final users = await getUsers();
    final exists = users.any((u) => u.email == user.email);
    if (!exists) {
      users.add(user);
      await saveUsers(users);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
