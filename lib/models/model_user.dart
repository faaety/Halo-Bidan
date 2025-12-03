import 'dart:convert';

class User {
  final String id;
  final String namaLengkap;
  final String email;
  final String password;
  final String phone;
  final String alamat;
  final String gender;
  final String? imagePath;
  final bool isAdmin;

  // ✅ Tambahan supaya kompatibel dengan HomePage
  final String category;   // contoh: "animals", "toys", "groups", "none"
  final String groupName;  // contoh: nama grup tempat user login

  User({
    required this.id,
    required this.namaLengkap,
    required this.email,
    required this.password,
    required this.phone,
    required this.alamat,
    required this.gender,
    this.imagePath,
    this.isAdmin = false,
    this.category = "none",   // default kalau tidak ada kategori
    this.groupName = "",      // default kosong
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaLengkap': namaLengkap,
      'email': email,
      'password': password,
      'phone': phone,
      'alamat': alamat,
      'gender': gender,
      'imagePath': imagePath,
      'isAdmin': isAdmin,
      'category': category,
      'groupName': groupName,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      namaLengkap: map['namaLengkap'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      alamat: map['alamat'] ?? '',
      gender: map['gender'] ?? '',
      imagePath: map['imagePath'],
      isAdmin: map['isAdmin'] ?? false,
      category: map['category'] ?? 'none',
      groupName: map['groupName'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) => User.fromMap(jsonDecode(source));

  @override
  String toString() {
    return 'User(id: $id, namaLengkap: $namaLengkap, email: $email, category: $category, groupName: $groupName)';
  }
}