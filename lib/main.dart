import 'package:flutter/material.dart';
import 'package:halobidan/login_screen.dart';
import 'local/data_user.dart';
import 'db_helper.dart';
import 'seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// INFO: Buat default admin user
  final userPref = UserPreferences();
  await userPref.createDefaultAdmin();

  /// INFO: Cek apakah database sudah ada isinya
  final db = DBHelper();
  await db.resetDataMember();
  await setData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homepage - User',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}