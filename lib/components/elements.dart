import 'package:flutter/material.dart';

class Elements {

  ///INFO: Future<DialogAction> → fungsi ini asinkron harus ditunggu dengan await
  static Future<DialogAction> confirmationDialog(BuildContext context, {
    String title = "Konfirmasi",
    String message = "Apakah Anda yakin?",
  }) async {
    final dialogAction = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, DialogAction.no),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, DialogAction.yes),
            child: Text("Yes"),
          ),
        ],
      ),
    );

    return dialogAction ?? DialogAction.neutral;
  }



}
/// INFO:enum DialogAction = tipe data khusus untuk menandai hasil dialog
enum DialogAction { yes, no, neutral }